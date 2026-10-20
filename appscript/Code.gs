/** MBN Mail bridge. Install in a dedicated project, executing as its owner. */
function initialiserMBNMail() {
  var props = PropertiesService.getScriptProperties();
  if (!props.getProperty('MBN_MAIL_SECRET')) {
    props.setProperty('MBN_MAIL_SECRET', (Utilities.getUuid() + Utilities.getUuid() + Utilities.getUuid()).replace(/-/g, ''));
  }
  if (!props.getProperty('MBN_MAIL_LEDGER_ID')) {
    var book = SpreadsheetApp.create('MBN Mail - journal technique prive');
    book.getSheets()[0].setName('Envois');
    book.getSheets()[0].appendRow(['message_id', 'sha256', 'status', 'updated_at']);
    props.setProperty('MBN_MAIL_LEDGER_ID', book.getId());
  }
  // Requests MailApp authorization without sending any message.
  return {sender: Session.getEffectiveUser().getEmail(), remaining: MailApp.getRemainingDailyQuota(), initialized: true};
}

function doGet() {
  return ContentService.createTextOutput(JSON.stringify({service: 'mbn-apps-script', version: 1})).setMimeType(ContentService.MimeType.JSON);
}

function mbnHex_(bytes) {return bytes.map(function (b) {return ('0' + ((b + 256) % 256).toString(16)).slice(-2);}).join('');}
function mbnMAC_(secret, value) {return mbnHex_(Utilities.computeHmacSha256Signature(value, secret, Utilities.Charset.UTF_8));}
function mbnEqual_(a, b) {var diff = a.length ^ b.length; for (var i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ (b.charCodeAt(i) || 0); return diff === 0;}
function mbnEmail_(value) {return typeof value === 'string' && value.length <= 254 && /^[^\s@,;<>]+@[^\s@,;<>]+\.[^\s@,;<>]+$/.test(value);}
function mbnOutput_(value) {return ContentService.createTextOutput(JSON.stringify(value)).setMimeType(ContentService.MimeType.JSON);}

function doPost(e) {
  var secret = PropertiesService.getScriptProperties().getProperty('MBN_MAIL_SECRET');
  var nonce;
  function reply(value) {
    var payload = JSON.stringify(Object.assign({nonce: nonce}, value));
    return mbnOutput_({payload: payload, signature: mbnMAC_(secret, nonce + '\n' + payload)});
  }
  try {
    if (!secret || !/^[A-Za-z0-9_-]{80,200}$/.test(secret) || !e || !e.postData || e.postData.contents.length > 28000000) throw Error();
    var envelope = JSON.parse(e.postData.contents);
    nonce = envelope.nonce;
    if (!/^[a-f0-9-]{36}$/.test(nonce) || !Number.isSafeInteger(envelope.timestamp) || Math.abs(Date.now() - envelope.timestamp) > 120000
        || typeof envelope.payload !== 'string' || !/^[a-f0-9]{64}$/.test(envelope.signature)
        || !mbnEqual_(mbnMAC_(secret, envelope.timestamp + '\n' + nonce + '\n' + envelope.payload), envelope.signature)) throw Error();
  } catch (_) {return mbnOutput_({error: 'authentication_required'});}
  var input;
  try {input = JSON.parse(envelope.payload);} catch (_) {return reply({error: 'appscript_invalid_request'});}
  var owner = Session.getEffectiveUser().getEmail().toLowerCase();
  if (!input.sender || !mbnEmail_(owner) || input.sender.from_email !== owner) return reply({error: 'appscript_sender_mismatch'});
  var ledgerId = PropertiesService.getScriptProperties().getProperty('MBN_MAIL_LEDGER_ID');
  if (!ledgerId) return reply({error: 'appscript_not_initialized'});
  if (input.action === 'inspect') {
    try {return reply({sender_email: owner, remaining: MailApp.getRemainingDailyQuota()});}
    catch (_) {return reply({error: 'appscript_authorization_required'});}
  }
  if (input.action !== 'send') return reply({error: 'appscript_invalid_request'});
  var message = input.message;
  function result(status, error) {return reply({message_id: message && message.id, status: status, error: error, provider_id: 'apps-script:' + (message && message.id)});}
  var attachments = [], total = 0;
  try {
    if (!message || !/^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/.test(message.id) || !mbnEmail_(message.recipient)
        || typeof message.subject !== 'string' || message.subject.length < 1 || message.subject.length > 200 || /[\r\n]/.test(message.subject)
        || typeof message.text !== 'string' || typeof message.html !== 'string'
        || Utilities.newBlob(message.text + message.html).getBytes().length > 150000
        || typeof input.sender.from_name !== 'string' || !input.sender.from_name || input.sender.from_name.length > 100 || /[\r\n]/.test(input.sender.from_name)
        || !mbnEmail_(input.sender.reply_to) || (message.attachments && (!Array.isArray(message.attachments) || message.attachments.length > 12))) throw Error();
    (message.attachments || []).forEach(function (a) {
      if (!a || typeof a.filename !== 'string' || !/^[a-zA-Z0-9_. -]{1,150}$/.test(a.filename) || !/\.(pdf|png|jpe?g)$/i.test(a.filename)
          || ['application/pdf', 'image/png', 'image/jpeg'].indexOf(a.mime_type) < 0 || typeof a.base64 !== 'string'
          || a.base64.length > 7000000 || a.base64.length % 4 !== 0 || !/^[A-Za-z0-9+/]+={0,2}$/.test(a.base64)) throw Error();
      var bytes = Utilities.base64Decode(a.base64); total += bytes.length;
      if (!bytes.length || bytes.length > 5242880 || total > 18874368) throw Error();
      attachments.push(Utilities.newBlob(bytes, a.mime_type, a.filename));
    });
  } catch (_) {return result('FAILED', 'appscript_invalid_message');}
  var lock = LockService.getScriptLock();
  if (!lock.tryLock(5000)) return result('FAILED', 'appscript_busy');
  try {
    var sheet = SpreadsheetApp.openById(ledgerId).getSheetByName('Envois');
    if (!sheet) return result('FAILED', 'appscript_not_initialized');
    var hash = mbnHex_(Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, envelope.payload, Utilities.Charset.UTF_8));
    var cell = sheet.getRange('A:A').createTextFinder(message.id).matchEntireCell(true).findNext();
    if (cell) {
      var previous = sheet.getRange(cell.getRow(), 1, 1, 4).getValues()[0];
      if (previous[1] !== hash) return result('UNCERTAIN', 'appscript_message_conflict');
      return previous[2] === 'ACCEPTED' ? result('ACCEPTED') : result('UNCERTAIN', 'appscript_acceptance_uncertain');
    }
    if (MailApp.getRemainingDailyQuota() < 1) return result('FAILED', 'appscript_quota_exhausted');
    // Persist before the irreversible send. A crash or unknown result is never retried.
    sheet.appendRow([message.id, hash, 'PENDING', new Date().toISOString()]);
    var row = sheet.getLastRow();
    SpreadsheetApp.flush();
    try {
      MailApp.sendEmail({to: message.recipient, subject: message.subject, body: message.text, htmlBody: message.html,
        name: input.sender.from_name, replyTo: input.sender.reply_to, attachments: attachments});
      sheet.getRange(row, 3, 1, 2).setValues([['ACCEPTED', new Date().toISOString()]]);
      SpreadsheetApp.flush();
      return result('ACCEPTED');
    } catch (_) {return result('UNCERTAIN', 'appscript_acceptance_uncertain');}
  } catch (_) {return result('UNCERTAIN', 'appscript_acceptance_uncertain');}
  finally {lock.releaseLock();}
}
