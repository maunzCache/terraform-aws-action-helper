#!/usr/bin/env python3

#########
# Usage #
#########
# Get/Cache information
# ./generate_module.py --docs-page list_amazonec2
#
# Generate submodule
# ./generate_module.py --docs-page list_amazonec2 --generate

#########
# TODOs #
#########
# Add unit tests
# Go through all TODOs in this file an resolve them

import argparse
import json
import urllib.request
from pathlib import Path
from typing import Tuple

from cookiecutter.main import cookiecutter
from lxml import html

aws_docs_base_url = 'https://docs.aws.amazon.com'
aws_docs_api_path = 'service-authorization/latest/reference'
# TODO: Use string helper method for concatination
aws_docs_url = f'{aws_docs_base_url}/{aws_docs_api_path}'

# Maybe an enum
html_access_levels = ['write', 'list', 'read',
                      'tagging', 'permissions_management']


def generate_service_list_from_html() -> dict:
    # TODO: Create local cache
    # We are lucky to have an "API" here.
    # Otherwise it would be bad because it uses some angular/react style lib for loading
    doc_url = f'{aws_docs_url}/toc-contents.json'

    with urllib.request.urlopen(doc_url) as response:
        response_bytes = response.read()
        json_string = response_bytes.decode('utf-8')

    service_dict: dict = {}
    try:
        json_content = json.loads(json_string)
        raw_service_page_list = json_content['contents'][0]['contents'][0]['contents']

        for raw_entry in raw_service_page_list:
            # TODO: Consider leaving the .html so that is more flexibel in the future
            # However, requires to be passed to all submethods
            link_name = raw_entry['href'].replace('.html', '')

            if link_name in service_dict.keys():
                print(f'Found duplicate: {link_name}')

            # Value should be the prefix/service name
            service_dict[link_name] = ''
    except Exception as e:
        # TODO: Lets make this better later
        print(e)

    write_service_list_cache(service_dict)

    return service_dict


def write_service_list_cache(service_dict: dict):
    # TODO: May override existing service names
    try:
        cache_file = Path('service_list.json')
        cache_file.write_text(json.dumps(service_dict, indent=2), 'utf-8')
    except Exception as e:
        # TODO: Lets make this better later
        print(e)


def load_service_list_cache() -> dict:
    service_list = {}
    cache_file = Path('service_list.json')
    if cache_file.exists():
        try:
            service_list_json = cache_file.read_text('utf-8')
            service_list = json.loads(service_list_json)
        except Exception as e:
            # TODO: Lets make this better later
            print(e)

    return service_list


def generate_actions_from_service(service_docs_page_name: str) -> Tuple[str, dict, str]:
    # TODO: Create local cache
    doc_url = f'{aws_docs_url}/{service_docs_page_name}.html'

    with urllib.request.urlopen(doc_url) as response:
        response_bytes = response.read()
        html_string = response_bytes.decode('utf-8')

    html_tree = html.fromstring(html_string)

    service_name_wrapper = html_tree.cssselect(
        '#main-col-body p code.code')

    # Assume first code tag contains the prefix name
    # TODO: Ensure that parent contains (service prefix: {{ THE_NAME }})
    service_prefix = service_name_wrapper[0].text
    # TODO: For now assume prefix and service name match
    service_name = service_prefix

    # Assumes that the first table is always the action table
    # document.getElementById('main-col-body').getElementsByClassName('table-contents')[0].getElementsByTagName('table')
    action_table = html_tree.cssselect(
        '#main-col-body .table-contents table')[0]

    # table head
    # <th>Actions</th>
    # <th>Description</th>
    # <th>Access level</th>
    # <th>Resource types (*required)</th>
    # <th>Condition keys</th>
    # <th>Dependent actions</th>
    table_rows = action_table.findall('tr')

    actions: dict = {
        'write': [],
        'permissions_management': [],
        'read': [],
        'list': [],
        'tagging': [],
    }
    for row in table_rows:
        row_data = row.findall('td')

        raw_access_data = row_data[2].text_content()
        access_level_data = raw_access_data.lower().replace(' ', '_')
        if access_level_data in html_access_levels:
            # Actions are links. Get the value from the second link in the td
            # Its to dangerous to parse the id of the first link
            try:
                html_text = row_data[0].findall('a')[1].text
            except Exception as e:
                print(
                    f'Action has to link to API. Use fallback. Original error:{e}')
                # TODO: Sanitizes strings that don't have API links. I don't know how to to this better currently.
                html_text = row_data[0].text_content().replace(
                    '\n', '').strip()
            actions[access_level_data].append(html_text)

    return (service_name, actions, service_prefix)


def generate_from_cookiecutter(service_name: str, service_docs_page_name: str, service_actions: dict, service_prefix: str):
    cookiecutter_vars = {
        'service_name': service_name,
        'service_docs_page_name': service_docs_page_name,
        'service_actions': service_actions,
        'service_prefix': service_prefix,
    }

    cookiecutter('./template/', no_input=True, extra_context=cookiecutter_vars,
                 overwrite_if_exists=True, output_dir='../modules')


def main(args: argparse.Namespace):
    # Notice: The script below is volatile and will fail if AWS changes the layout
    # Maybe there will be some kind of API or other source of truth for this kind of information
    # Making everything here obsolete
    # But it was fun while it last

    # Implement:
    # For each page, look for the service prefix hardcoded in (service prefix: {{ THE_NAME }})
    # Map the value to the page or vice-versa. The service prefix will be the service name
    # Save this information once, only fetch on demand
    #
    # For cookicutter:
    # Note: Beware of special cases! e.g. (permission only) added as suffix or empty tables or more than one word permissions

    service_list = load_service_list_cache()
    if len(service_list) == 0:
        service_list = generate_service_list_from_html()

    docs_page_name = args.docs_page
    if docs_page_name in service_list:
        service_name, actions, service_prefix = generate_actions_from_service(
            docs_page_name)

        service_list[docs_page_name] = service_name
        write_service_list_cache(service_list)
    else:
        print('Docs page does not exist')
        exit(0)

    if args.generate:
        generate_from_cookiecutter(
            service_name, docs_page_name, actions, service_prefix)


if __name__ == '__main__':
    # TODO: Implement simple arg parse for only doing one of the things
    # Or all at once

    parser = argparse.ArgumentParser(description='TODO: Write me please')
    parser.add_argument('--docs-page', type=str, help='TODO: Write me please')
    # TODO: Below not implemented yet. Should only work if cache has been created or force cache creation
    parser.add_argument('--service_name', type=str,
                        help='TODO: Write me please')
    parser.add_argument('--generate', action='store_true',
                        help='TODO: Write me please')

    args = parser.parse_args()

    main(args)
