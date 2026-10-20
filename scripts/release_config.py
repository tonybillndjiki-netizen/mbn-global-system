"""Public build configuration. No privileged credential belongs in generated files."""
import base64
import json
import os
import re
from dataclasses import dataclass

SOURCE_REF = 'ppqeuluykiknuujfaoid'
SOURCE_ORIGIN = 'https://mbn-global.netlify.app'
SOURCE_KEY = 'sb_publishable_NGnS0aBO4WUBbL6EbgMr0A_ad6EfOzS'


@dataclass(frozen=True)
class Target:
    ref: str
    key: str
    origin: str

    @property
    def url(self):
        return f'https://{self.ref}.supabase.co'

    def rewrite(self, text):
        return text.replace(SOURCE_REF, self.ref).replace(SOURCE_KEY, self.key).replace(SOURCE_ORIGIN, self.origin)


def target_from_env(env=None, required=False):
    env = os.environ if env is None else env
    values = [env.get(k, '') for k in ('MBN_SUPABASE_PROJECT_REF', 'MBN_SUPABASE_PUBLISHABLE_KEY', 'MBN_PUBLIC_ORIGIN')]
    if not any(values) and not required:
        return None
    ref, key, origin = values
    if not re.fullmatch(r'[a-z0-9]{20}', ref):
        raise ValueError('MBN_SUPABASE_PROJECT_REF must contain 20 lowercase letters/digits')
    if not re.fullmatch(r'https://[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?', origin) or '..' in origin:
        raise ValueError('MBN_PUBLIC_ORIGIN must be an HTTPS origin without path, port or trailing slash')
    if not re.fullmatch(r'sb_publishable_[A-Za-z0-9_-]{10,200}', key):
        # Legacy keys are allowed only when explicitly labelled anon for this project.
        try:
            if not re.fullmatch(r'[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+', key):
                raise ValueError()
            claims = json.loads(base64.urlsafe_b64decode(key.split('.')[1] + '==='))
            if claims.get('role') != 'anon' or claims.get('ref') != ref:
                raise ValueError()
        except (ValueError, TypeError, KeyError):
            raise ValueError('Only a public publishable key or project-matching anon JWT is allowed') from None
    return Target(ref, key, origin)
