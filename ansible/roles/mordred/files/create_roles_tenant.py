#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2022 Bitergia
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Authors:
#     Quan Zhou <quan@bitergia.com>
#


import argparse
import json
from enum import Enum
from string import Template

import requests


API_ROLES = "/_plugins/_security/api/roles/"
API_TENANT = "/_plugins/_security/api/tenants/"
API_ROLESMAPPING = "/_plugins/_security/api/rolesmapping/"

# Backend roles
BACKEND_ROLE_ANONYMOUS = "opendistro_security_anonymous_backendrole"
BACKEND_ROLE_HIDE_PLUGINS = "hide_plugins"
BACKEND_ROLE_PRIVILEGED = "{}_privileged"
BACKEND_ROLE_PSEUDONYMIZE = "{}_pseudonymize"
BACKEND_ROLE_USER = "{}_user"

# ROLES
BAP_PLUGINS_ROLE = Template('''{
    "cluster_permissions": [],
    "index_permissions": [],
    "tenant_permissions": []
}''')
BAP_TENANT_PRIVILEGED_USER_ROLE = Template('''{
    "cluster_permissions": [
        "cluster_composite_ops"
    ],
    "index_permissions": [
        {
            "index_patterns": [
                "grimoirelab_${tenant}_*",
                "bap_${tenant}_*",
                "custom_${tenant}_*",
                "c_${tenant}_*"
            ],
            "allowed_actions": [
                "read"
            ]
        },
        {
            "index_patterns": [
                ".kibana",
                ".kibana_*_${tenant}_*",
                ".opensearch_dashboards",
                ".opensearch_dashboards_*_${tenant}_*"
            ],
            "allowed_actions": [
                "read",
                "delete",
                "manage",
                "index"
            ]
        },
        {
            "index_patterns": [
                ".tasks",
                ".management-beats",
                "*:.tasks",
                "*:.management-beats"
            ],
            "allowed_actions": [
                "indices_all"
            ]
        }
    ],
    "tenant_permissions": [
        {
            "tenant_patterns": [
                "${tenant}"
            ],
            "allowed_actions": [
                "kibana_all_write"
            ]
        }
    ]
}''')
BAP_TENANT_PSEUDONYMIZE_ROLE = Template('''{
    "cluster_permissions": [
        "cluster_composite_ops_ro"
    ],
    "index_permissions": [
        {
            "index_patterns": [
                "grimoirelab_${tenant}_*",
                "bap_${tenant}_*",
                "custom_${tenant}_*",
                "c_${tenant}_*"
            ],
            "allowed_actions": [
                "read"
            ],
            "dls": "",
            "fls": [],
            "masked_fields": [
                "committer",
                "owner",
                "*data_name",
                "*multi_names",
                "*ommitter_name",
                "*ommit_name",
                "*ssignee_name",
                "*user_name",
                "*uthor_name",
                "*username",
                "*_login"
            ]
        },
        {
            "index_patterns": [
                ".kibana",
                ".kibana_*_${tenant}_*",
                ".opensearch_dashboards",
                ".opensearch_dashboards_*_${tenant}_*"
            ],
            "allowed_actions": [
                "read"
            ]
        }
    ],
    "tenant_permissions": [
        {
            "tenant_patterns": [
                "${tenant}"
            ],
            "allowed_actions": [
                "kibana_all_read"
            ]
        }
    ]
}''')
BAP_TENANT_USER_ROLE = Template('''{
    "cluster_permissions": [
        "cluster_composite_ops_ro"
    ],
    "index_permissions": [
        {
            "index_patterns": [
                "grimoirelab_${tenant}_*",
                "bap_${tenant}_*",
                "custom_${tenant}_*",
                "c_${tenant}_*"
            ],
            "allowed_actions": [
                "read"
            ]
        },
        {
            "index_patterns": [
                ".kibana",
                ".kibana_*_${tenant}_*",
                ".opensearch_dashboards",
                ".opensearch_dashboards_*_${tenant}_*"
            ],
            "allowed_actions": [
                "read"
            ]
        }
    ],
    "tenant_permissions": [
        {
            "tenant_patterns": [
                "${tenant}"
            ],
            "allowed_actions": [
                "kibana_all_read"
            ]
        }
    ]
}''')
BAP_TENANT_MORDRED_ROLE = Template('''{
    "cluster_permissions": [
        "cluster_composite_ops_ro",
        "cluster_monitor",
        "indices:data/read/scroll/clear",
        "indices:data/write/bulk"
    ],
    "index_permissions": [
        {
            "index_patterns": [
                "grimoirelab_${tenant}_*",
                "bap_${tenant}_*",
                "custom_${tenant}_*",
                "c_${tenant}_*"
            ],
            "allowed_actions": [
                "indices_all"
            ]
        },
        {
            "index_patterns": [
                "*"
            ],
            "allowed_actions": [
                "manage_aliases"
            ]
        }
    ]
}''')

ROLES_MAPPING = {
    "bap_plugins_visibility": BAP_PLUGINS_ROLE,
    "bap_tenant_anonymous_access_role": BAP_TENANT_USER_ROLE,
    "bap_tenant_privileged_user_role": BAP_TENANT_PRIVILEGED_USER_ROLE,
    "bap_tenant_pseudonymize_role": BAP_TENANT_PSEUDONYMIZE_ROLE,
    "bap_tenant_user_role": BAP_TENANT_USER_ROLE,
    "bap_tenant_mordred_role": BAP_TENANT_MORDRED_ROLE
}


class Query(Enum):
    ROLE = API_ROLES
    TENANT = API_TENANT
    ROLESMAPPING = API_ROLESMAPPING


def main():
    args = args_parser()
    opensearch_url = args.opensearch_url
    tenant = args.tenant
    anonymous = args.anonymous
    force = args.force

    create_roles(anonymous, opensearch_url, tenant, force)
    create_tenant(opensearch_url, tenant, force)
    roles = get_roles(opensearch_url, tenant)
    for role in roles:
        if "privileged" in role:
            user = BACKEND_ROLE_PRIVILEGED.format(tenant)
        elif "user" in role:
            user = BACKEND_ROLE_USER.format(tenant)
        elif "anonymous" in role:
            user = BACKEND_ROLE_ANONYMOUS
        elif "pseudonymize" in role:
            user = BACKEND_ROLE_PSEUDONYMIZE.format(tenant)
        elif "plugins_visibility" in role:
            user = BACKEND_ROLE_HIDE_PLUGINS
        elif "mordred" in role:
            continue
        map_user(opensearch_url, role, user)


def args_parser():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("opensearch_url",
                        help="OpenSearch URL")
    parser.add_argument("tenant",
                        help="Name of the tenant")
    parser.add_argument("-a", "--anonymous",
                        action="store_true",
                        help="Create bap_anonymous_access role")
    parser.add_argument("-f", "--force",
                        action="store_true",
                        help="Overwrite roles and tenant")
    args = parser.parse_args()

    return args


def create_roles(anonymous, opensearch_url, tenant, force=False):
    for role in ROLES_MAPPING:
        if not anonymous and role == "bap_tenant_anonymous_access_role":
            continue

        role_name = role.replace("tenant", tenant)
        if not force and exists(opensearch_url, role_name, Query.ROLE):
            print("The role '{}' already exists".format(role_name))
            continue
        data = ROLES_MAPPING[role]
        data = data.substitute(tenant=tenant)
        base_url = opensearch_url + API_ROLES + role_name
        response = run_requests("PUT", base_url, data=data)
        print("{}: {}".format(response['status'], response['message']))

def get_roles(opensearch_url, tenant):
    roles = []
    base_url = opensearch_url + API_ROLES
    response = run_requests("GET", base_url)
    for role in response:
        if "plugins_visibility" in role or tenant in role:
            roles.append(role)
    
    return roles

def create_tenant(opensearch_url, tenant, force=False):
    if not force and exists(opensearch_url, tenant, Query.TENANT):
        print("The tenant '{}' already exists".format(tenant))
        return
    base_url = opensearch_url + API_TENANT + tenant
    data = '{"description": "Tenant created automatically."}'
    response = run_requests("PUT", base_url, data=data)
    print("{}: {}".format(response['status'], response['message']))

def map_user(opensearch_url, role_name, user):
    if not exists(opensearch_url, role_name, Query.ROLESMAPPING):
        base_url = opensearch_url + API_ROLESMAPPING + role_name
        data = {"backend_roles" : [user]}
        response = run_requests("PUT", base_url, data=json.dumps(data))
        print("{}: {}".format(response['status'], response['message']))

def exists(url, name, query_api):
    if not isinstance(query_api, Query):
        raise TypeError('query_api must be an instance of Query Enum')

    base_url = url + query_api.value + name
    try:
        _ = run_requests("GET", base_url)
        return True
    except requests.exceptions.HTTPError:
        return False


def run_requests(method, url, data=None, verify=False):
    headers = {'Content-type': 'application/json'}
    if method == "GET":
        r = requests.get(url, verify=verify, headers=headers)
    elif method == "POST":
        r = requests.post(url, data=data, verify=verify, headers=headers)
    elif method == "PUT":
        r = requests.put(url, data=data, verify=verify, headers=headers)
    elif method == "PATCH":
        r = requests.patch(url, data=data, verify=verify, headers=headers)

    r.raise_for_status()
    return r.json()


if __name__ == '__main__':
    main()
