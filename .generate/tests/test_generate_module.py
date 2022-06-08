import json
from unittest import mock

from generate_module import (generate_actions_from_service,
                             generate_from_cookiecutter,
                             generate_service_list_from_html,
                             get_file_content_from_url, load_service_list_cache,
                             main, write_service_list_cache)


@mock.patch('generate_module.get_file_content_from_url')
def test_generate_service_list_from_html(mock_file_content):
    dummy_page_name = 'link_to_page'
    dummy_json_as_dict = {
        'contents': [{
            'contents': [{
                'contents': [{
                    'href': f'{dummy_page_name}.html',
                }]
            }]
        }]
    }
    mock_file_content.return_value = json.dumps(
        dummy_json_as_dict)
    expected_result = {
        f'{dummy_page_name}': ''
    }

    actual_result: dict = generate_service_list_from_html()

    assert expected_result == actual_result


# TODO: Find out how to mock urllib
# def test_get_file_content_from_url():
#     actual_result = get_file_content_from_url()


# TODO: Find out how to mock urllib
# def test_write_service_list_cache():
#     actual_result = write_service_list_cache()


# TODO: Find out how to mock Pathlib
# def test_load_service_list_cache():
#     expected_result = {}
#
#     actual_result: dict = load_service_list_cache()
#
#     assert expected_result == actual_result


@mock.patch('generate_module.get_file_content_from_url')
def test_generate_actions_from_service_returns_service_name(mock_file_content):
    dummy_service_name = 'my-service-name'
    dummy_html_as_str = f'''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Dummy HTML</title>
    </head>
    <body>
        <div id="main-col-body">
            <p>
                <code class="code">{dummy_service_name}</code>
            </p>
            <div class="table-contents">
                <table>
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                    </tr>
                </table>
            </div>
        </div>
    </body>
    </html>
    '''
    mock_file_content.return_value = dummy_html_as_str

    test_service_docs_page_name = 'whatever'

    expected_result = dummy_service_name

    actual_result, _, _ = generate_actions_from_service(
        test_service_docs_page_name)

    assert expected_result == actual_result


@mock.patch('generate_module.get_file_content_from_url')
def test_generate_actions_from_service_returns_actions(mock_file_content):
    dummy_service_name = 'my-service-name'
    dummy_write_action = 'my-action'
    dummy_html_as_str = f'''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Dummy HTML</title>
    </head>
    <body>
        <div id="main-col-body">
            <p>
                <code class="code">{dummy_service_name}</code>
            </p>
            <div class="table-contents">
                <table>
                    <tr>
                        <td>
                            <a>Some cool link</a>
                            <a>{dummy_write_action}</a>
                        </td>
                        <td></td>
                        <td>Write</td>
                    </tr>
                </table>
            </div>
        </div>
    </body>
    </html>
    '''
    mock_file_content.return_value = dummy_html_as_str

    test_service_docs_page_name = 'whatever'

    expected_result = {
        'list': [],
        'permissions_management': [],
        'read': [],
        'tagging': [],
        'write': [dummy_write_action]
    }

    _, actual_result, _ = generate_actions_from_service(
        test_service_docs_page_name)

    assert expected_result == actual_result


@mock.patch('generate_module.get_file_content_from_url')
def test_generate_actions_from_service_returns_service_prefix(mock_file_content):
    dummy_service_name = 'my-service-name'
    dummy_write_action = 'my-action'
    dummy_html_as_str = f'''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Dummy HTML</title>
    </head>
    <body>
        <div id="main-col-body">
            <p>
                <code class="code">{dummy_service_name}</code>
            </p>
            <div class="table-contents">
                <table>
                    <tr>
                        <td>
                            <a>Some cool link</a>
                            <a>{dummy_write_action}</a>
                        </td>
                        <td></td>
                        <td>Write</td>
                    </tr>
                </table>
            </div>
        </div>
    </body>
    </html>
    '''
    mock_file_content.return_value = dummy_html_as_str

    test_service_docs_page_name = 'whatever'

    expected_result = dummy_service_name

    _, _, actual_result = generate_actions_from_service(
        test_service_docs_page_name)

    assert expected_result == actual_result


# def test_generate_from_cookiecutter():
#     actual_result = generate_from_cookiecutter()


# def test_main():
#     actual_result = main()
