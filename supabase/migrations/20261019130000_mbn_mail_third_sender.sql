-- A sender group is an email routing choice, not a legal entity or a campus.
-- Keep existing school routes and sender proofs when adding a third identity.
alter table private.mbn_mail_sender_groups
 drop constraint mbn_mail_sender_groups_code_check,
 add constraint mbn_mail_sender_groups_code_check
 check(code in ('MBN_GLOBAL','CAMPUS_INNOVATION_MLV','ADMISSIONS_COMMUN'));

insert into private.mbn_mail_sender_groups(code,from_name)
 values('ADMISSIONS_COMMUN','Service admissions');

-- This profile starts paused, with no address or school assignments.
-- Existing mail_route_save lets administrators move any school between the
-- three groups. Its revision invalidates any outstanding, obsolete send lease.
