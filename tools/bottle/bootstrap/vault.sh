#!/bin/bash

# Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
set -e

# load environment variables
source ./scripts/load-env.sh

# configure userpass auth
vault auth enable userpass
vault write auth/userpass/users/admin \
  password=changeme \
  policies=admins

vault policy write admins - <<EOF
# Allow managing leases
path "sys/leases/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["read","list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secret engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secret engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}
EOF

# configure vault as oidc provider
vault policy write oidc-auth - <<EOF
path "identity/oidc/provider/my-provider/authorize" {
capabilities = [ "read" ]
}
EOF

vault write auth/userpass/users/demo \
  password=changeme \
  token_policies=oidc-auth \
  token_ttl=1h
vault write identity/entity \
  name=demo \
  metadata=email=none@none \
  disabled=false

ENTITY_ID=$(vault read -field=id identity/entity/name/demo)
vault write identity/group \
  name=users \
  member_entity_ids="${ENTITY_ID}"
GROUP_ID="$(vault read -field=id identity/group/name/users)"
USERPASS_ACCESSOR="$(vault auth list -detailed -format json | jq -r '.["userpass/"].accessor')"
vault write identity/entity-alias \
  name=demo \
  canonical_id="${ENTITY_ID}" \
  mount_accessor="${USERPASS_ACCESSOR}"

vault write identity/oidc/assignment/default \
  entity_ids="${ENTITY_ID}" \
  group_ids="${GROUP_ID}"
vault write identity/oidc/key/default \
  allowed_client_ids="*" \
  verification_ttl=2h \
  rotation_period=1h \
  algorithm=RS256
vault write identity/oidc/client/pinniped \
  redirect_uris=http://127.0.0.1:8080/v1/auth-methods/oidc/callback \
  assignments=default \
  key=default \
  id_token_ttl=30m \
  access_token_ttl=1h
CLIENT_ID="$(vault read -field=client_id identity/oidc/client/pinniped)"

USER_SCOPE_TEMPLATE='{
    "username": {{identity.entity.name}},
    "contact": {
        "email": {{identity.entity.metadata.email}},
        "phone_number": {{identity.entity.metadata.phone_number}}
    }
}'
vault write identity/oidc/scope/user \
  description="The user scope provides claims using Vault identity entity metadata" \
  template="$(echo "${USER_SCOPE_TEMPLATE}" | base64 -)"
GROUPS_SCOPE_TEMPLATE='{
    "groups": {{identity.entity.groups.names}}
}'
vault write identity/oidc/scope/groups \
  description="The groups scope provides the groups claim using Vault group membership" \
  template="$(echo "${GROUPS_SCOPE_TEMPLATE}" | base64 -)"
vault write identity/oidc/provider/vault \
  allowed_client_ids="${CLIENT_ID}" \
  scopes_supported="groups,user"

# configure vault approle for MAAS

# configure MAAS secret mount
