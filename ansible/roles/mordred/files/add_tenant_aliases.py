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
import logging

import requests


# Logging formats
LOG_FORMAT = "[%(asctime)s - %(levelname)s] - %(message)s"


logger = logging.getLogger(__name__)


def main():
    args = parse_args()

    if args.debug:
        logging.basicConfig(level=logging.DEBUG, format=LOG_FORMAT)
    else:
        logging.basicConfig(level=logging.INFO, format=LOG_FORMAT)

    logger.info("Update aliases JSON file starting...")

    aliases_json = read_json(args.input)
    tenant = args.tenant
    logger.debug("Tenant: {}".format(tenant))
    update_aliases(aliases_json, tenant)
    output_name = args.output if args.output else args.input
    write_json(output_name, aliases_json)

    logger.info("Done")


def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("input",
                        help="Aliases JSON file")
    parser.add_argument("tenant",
                        help="Tenant")
    parser.add_argument("-o", "--output",
                        help="Output aliases JSON file")
    parser.add_argument("-g", "--debug",
                        action='store_true',
                        help="Debug mode")
    args = parser.parse_args()
    return args


def read_json(file_name):
    logger.debug("Reading: {}".format(file_name))
    with open(file_name, "r") as f:
        return json.loads(f.read())


def update_aliases(data, tenant):
    for backend in data:
        for phase in data[backend]:
            for alias in data[backend][phase]:
                logger.debug("Original backend/phase/alias: {}/{}/{}".format(backend, phase, alias['alias']))
                alias['alias'] = add_tenant(tenant, alias['alias'])
                logger.debug("Updated backend/phase/alias: {}/{}/{}".format(backend, phase, alias['alias']))


def add_tenant(tenant, name):
    new_name = "{}_{}".format(tenant, name)
    return new_name


def write_json(file_name, data):
    logger.info("Output file: {}".format(file_name))
    with open(file_name, "w+") as f:
        f.write(json.dumps(data, indent=4))


if __name__ == '__main__':
    main()