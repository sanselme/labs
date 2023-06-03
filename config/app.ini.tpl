APP_NAME = Gitea: gitea.${SITE}.${DOMAIN}
RUN_USER = admin
RUN_MODE = prod

[database]
DB_TYPE  = sqlite3
HOST     = 127.0.0.1:1433
NAME     = gitea
USER     = gitea
PASSWD   =
SCHEMA   =
SSL_MODE = disable
CHARSET  = utf8
PATH     = ${GITEA_ROOT_PATH}/gitea.db
LOG_SQL  = false

[repository]
ROOT = ${GITEA_ROOT_PATH}/gitea-repositories

[server]
PROTOCOL         = https
SSH_DOMAIN       = gitea.${SITE}.${DOMAIN}
DOMAIN           = gitea.${SITE}.${DOMAIN}
HTTP_ADDR        = ${GITEA_HTTP_ADDR}
HTTP_PORT        = 3000
ROOT_URL         = https://gitea.${SITE}.${DOMAIN}:3000/
DISABLE_SSH      = false
SSH_PORT         = 22
LFS_START_SERVER = true
LFS_JWT_SECRET   = ${GITEA_JWT_SECRET}
LFS_CONTENT_PATH = ${GITEA_ROOT_PATH}/lfs
OFFLINE_MODE     = false
CERT_FILE        = cert.pem
KEY_FILE         = key.pem

[lfs]
; PATH = ${GITEA_ROOT_PATH}/lfs
STORAGE_TYPE = minio

[mailer]
ENABLED = false

[service]
REGISTER_EMAIL_CONFIRM            = false
ENABLE_NOTIFY_MAIL                = false
DISABLE_REGISTRATION              = false
ALLOW_ONLY_INTERNAL_REGISTRATION  = false
ALLOW_ONLY_EXTERNAL_REGISTRATION  = true
ENABLE_CAPTCHA                    = false
REQUIRE_SIGNIN_VIEW               = false
DEFAULT_KEEP_EMAIL_PRIVATE        = false
DEFAULT_ALLOW_CREATE_ORGANIZATION = false
DEFAULT_ENABLE_TIMETRACKING       = true
NO_REPLY_ADDRESS                  = noreply.gitea.${SITE}.${DOMAIN}

[openid]
ENABLE_OPENID_SIGNIN = false
ENABLE_OPENID_SIGNUP = true
WHITELISTED_URIS     = ${OIDC_WHITELISTED_URIS}

[oauth2_client]
ENABLE_AUTO_REGISTRATION    = true
ACCOUNT_LINKING             = true

[oauth2]
ENABLE = false

[cron.update_checker]
ENABLED = false

[session]
PROVIDER = file

[log]
MODE      = console
LEVEL     = info
ROOT_PATH = /var/log
ROUTER    = console

[repository.pull-request]
DEFAULT_MERGE_STYLE = merge

[repository.signing]
DEFAULT_TRUST_MODEL =  committer
SIGNING_KEY = default
SIGNING_NAME =
SIGNING_EMAIL =
INITIAL_COMMIT = always
CRUD_ACTIONS = always
WIKI = always
MERGES = always

[repository.local]
LOCAL_COPY_PATH = ${GITEA_ROOT_PATH}/local-repo

[repository.upload]
TEMP_PATH = ${GITEA_ROOT_PATH}/uploads

[security]
INSTALL_LOCK       = true
INTERNAL_TOKEN     = ${GITEA_INTERNAL_TOKEN}
PASSWORD_HASH_ALGO = pbkdf2

[actions]
ENABLED = true
DEFAULT_ACTIONS_URL = https://github.com

[attachment]
STORAGE_TYPE = minio
MINIO_BASE_PATH = /attachment

[storage.minio]
STORAGE_TYPE = minio
MINIO_ENDPOINT = ${MINIO_ENDPOINT}
MINIO_ACCESS_KEY_ID = ${MINIO_ACCESS_KEY_ID}
MINIO_SECRET_ACCESS_KEY = ${MINIO_SECRET_ACCESS_KEY}
MINIO_BUCKET = gitea
MINIO_LOCATION = us-east-1
MINIO_USE_SSL = true
MINIO_INSECURE_SKIP_VERIFY = false
