"""
General information
###################
This script is volatile and will fail if AWS changes the layout of their documentation.
Maybe there will be some kind of API or other source of truth for this kind of information,
Making everything here obsolete, but it was fun while it lasted.

TODO: Consider generating from https://awspolicygen.s3.amazonaws.com/js/policies.js
TODO: Replace template file name with simple service name

Usage
#####
Create service_list.json
python -m generate_module

Get/Cache all information for service_list.json
python -m generate_module --all

Generate all submodules to modules/ directory
python -m generate_module --all --generate

Get/Cache information for service_list.json
python -m generate_module --docs-page list_amazonec2

Generate submodule to modules/ directory
python -m generate_module --docs-page list_amazonec2 --generate
"""

import argparse
import json
import logging
import urllib.request
from pathlib import Path
from typing import Tuple

from cookiecutter.main import cookiecutter
from lxml import html

logging.basicConfig(level=logging.INFO)

service_list_cache_name = 'service_list.json'

aws_docs_base_url = 'https://docs.aws.amazon.com'
aws_docs_api_path = 'service-authorization/latest/reference'
aws_docs_url = f'{aws_docs_base_url}/{aws_docs_api_path}'

html_access_levels = ['write', 'list', 'read',
                      'tagging', 'permissions_management']


def main(args: argparse.Namespace):
    service_list = load_service_list_cache()
    if len(service_list) == 0:
        service_list = generate_service_list_from_html()

    if args.all:
        # TODO: Deduplicate code from args.docs_page case
        for page_name in service_list:
            try:
                service_name, actions, service_prefix = generate_actions_from_service(
                    page_name)

                service_list[page_name] = service_name
                write_service_list_cache(service_list)
            except Exception as e:
                # TODO: Lets make this better later
                logging.error(e)

            if args.generate:
                try:
                    generate_from_cookiecutter(
                        service_name, page_name, actions, service_prefix)
                except Exception as e:
                    # TODO: Lets make this better later
                    logging.error(e)
    elif args.docs_page:
        docs_page_name = args.docs_page
        if docs_page_name in service_list:
            service_name, actions, service_prefix = generate_actions_from_service(
                docs_page_name)

            service_list[docs_page_name] = service_name
            write_service_list_cache(service_list)
        else:
            logging.error('Docs page does not exist.')
            exit(0)

        if args.generate:
            generate_from_cookiecutter(
                service_name, docs_page_name, actions, service_prefix)


def load_service_list_cache() -> dict:
    service_list = {}
    cache_file = Path(service_list_cache_name)
    if cache_file.exists():
        try:
            service_list_json = cache_file.read_text('utf-8')
            service_list = json.loads(service_list_json)
        except Exception as e:
            # TODO: Lets make this better later
            logging.error(e)

    return service_list


def generate_service_list_from_html() -> dict:
    # File containing the document structure of the service documentation
    doc_url = f'{aws_docs_url}/toc-contents.json'
    json_string = get_file_content_from_url(doc_url)

    service_dict: dict = {}
    try:
        json_content = json.loads(json_string)
        raw_service_page_list = json_content['contents'][0]['contents'][0]['contents']
        logging.debug(raw_service_page_list)

        # Iterate through all navigation items
        for raw_entry in raw_service_page_list:
            # TODO: Consider leaving the .html so that is more flexibel in the future
            link_name = raw_entry['href'].replace('.html', '')

            # Warn if a service contains duplicates
            # TODO: Investigate if this is an issue
            if link_name in service_dict.keys():
                logging.debug(f'Found duplicate: {link_name}')

            # Set empty value for the cache
            service_dict[link_name] = ''
    except Exception as e:
        # TODO: Lets make this better later
        logging.error(e)

    write_service_list_cache(service_dict)

    service_list = service_dict.copy()
    # TODO: Current workaround to prefill the service_list.json
    # for docs_service_page in service_list.keys():
    #     generate_actions_from_service(docs_service_page)
    #
    #     service_name, _, _ = generate_actions_from_service(
    #         docs_service_page)
    #
    #     service_list[docs_service_page] = service_name
    #
    # TODO: Too many writes. Loses results if generating has any errors.
    # write_service_list_cache(service_list)

    return service_list


def generate_actions_from_service(service_docs_page_name: str) -> Tuple[str, dict, str]:
    # TODO: Create local cache for each HTML file
    doc_url = f'{aws_docs_url}/{service_docs_page_name}.html'
    html_string = get_file_content_from_url(doc_url)
    html_tree = html.fromstring(html_string)

    # Note: This is volatile if the markup changes
    service_name_wrapper = html_tree.cssselect('#main-col-body p code.code')
    # logging.debug(service_name_wrapper)

    # Assume first 'code' tag contains the prefix name
    service_prefix = service_name_wrapper[0].text
    logging.debug(service_prefix)

    # TODO: Not working for awsiq
    service_name = service_docs_page_name.replace('list_', '')  # TODO: Replace special chars for terraform.
    logging.debug(f'{service_prefix}/{service_name}')

    # Assumes that the first 'table' tag is always the action table
    action_table = html_tree.cssselect(
        '#main-col-body .table-contents table')[0]
    # logging.debug(action_table)

    # Table head
    # <th>Actions</th>
    # <th>Description</th>
    # <th>Access level</th>
    # <th>Resource types (*required)</th>
    # <th>Condition keys</th>
    # <th>Dependent actions</th>
    table_rows = action_table.findall('tr')
    # logging.debug(table_rows)

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
            # Its to volatile to parse the id of the first link
            try:
                a_id_text = row_data[0].findall('a')[0].attrib.get('id')
                a_id_text = a_id_text.replace(f'{service_name}-', '')
            except Exception as e:
                logging.warning(
                    f'Action has link to API. Use fallback. Original error:{e}')
                # TODO: Sanitizes strings that don't have API links. I don't know how to to this better currently.
                a_id_text = row_data[0].text_content().replace(
                    '\n', '').strip()
            final_action_name = a_id_text.replace('[permission only]', '').strip()
            actions[access_level_data].append(final_action_name)

    return (service_name, actions, service_prefix)


def get_file_content_from_url(url: str) -> str:
    json_string = ''

    with urllib.request.urlopen(url) as response:
        response_bytes = response.read()
        json_string = response_bytes.decode('utf-8')

        # TODO: Calc hash and save to file

    return json_string


def write_service_list_cache(service_dict: dict):
    try:
        # Note: Will be written where script is executed
        cache_file = Path(service_list_cache_name)
        cache_file.write_text(json.dumps(service_dict, indent=2), 'utf-8')
    except Exception as e:
        # TODO: Lets make this better later
        logging.error(e)


def generate_from_cookiecutter(service_name: str, service_docs_page_name: str, service_actions: dict, service_prefix: str):
    # TODO: If service_name has duplicates, modules will be overridden

    cookiecutter_vars = {
        'service_name': service_name.removeprefix('aws').removeprefix('amazon'),
        'service_docs_page_name': service_docs_page_name,
        'service_actions': service_actions,
        'service_prefix': service_prefix,
    }

    cookiecutter('./template/', no_input=True, extra_context=cookiecutter_vars,
                 overwrite_if_exists=True, output_dir='../modules')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Generate submodules based on the AWS service documentation page. Does only cache information by default.')
    # TODO: Make parser aware of argument mutex between all and docs-page
    parser.add_argument('--all', action='store_true',
                        help='Use this flag to consider all services. Mutually exclusive to --docs-page')
    parser.add_argument('--docs-page', type=str,
                        help='Filename of the service without the file type e.g. list_amazonec2.')
    # parser.add_argument('--service_name', type=str,
    #                     help='TODO: Implement me please')
    parser.add_argument('--generate', action='store_true',
                        help='Use this flag to generate the module.')

    args = parser.parse_args()

    main(args)
