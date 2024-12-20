from __future__ import print_function, unicode_literals
import os, sys
import shutil
import json
import re

from InquirerPy import prompt
from InquirerPy.separator import Separator
from InquirerPy.base import Choice
from jinja2 import Environment, FileSystemLoader, select_autoescape

from jumpstart.prompting import narg_input


# Create the Jinja2 environment and loader
env = Environment(
    loader=FileSystemLoader('templates'),
    autoescape=select_autoescape(),
    auto_reload=True # only set this to True in development
)

def main():
    """
    Entrypoint. Executes a series of interactive prompts to get user input for project settings.

    Usage: `python app.py` or `python app.py settings.json`
    """
    if len(sys.argv) > 1:
        infile = sys.argv[1]
        print(f"Loading settings from {infile}...")
        with open(infile, 'r', encoding='utf-8') as f:
            settings = json.load(f)
        _run(settings)
        return

    # Execute series of interactive prompts to get user input
    # (choose your own adventure style)
    questions = [
        {
            'type': 'input',
            'name': 'name',
            'message': 'Give this project a name',
            'default': 'hello_world',
            'validate': lambda name: re.match(r'^[a-z][a-z0-9_]+$', name) is not None
        },
        # Check if rendered folder already exists
        {
            'type': 'confirm',
            'name': 'overwrite',
            'message': 'Folder already exists. Overwrite?',
            'default': True,
            'when': lambda answers: os.path.exists(answers['name'])
        },
        {
            'type': 'list',
            'name': 'cloud',
            'message': 'What cloud provider do you use',
            'choices': ['AWS', 'Azure'],
            'default': 0
        },
        {
            'type': 'input',
            'name': 'aws_account_id',
            'message': 'What is your AWS account ID',
            'when': lambda answers: answers['cloud'] == 'AWS',
            'validate': lambda aws_account_id: re.match(r'^[0-9]{12}$', aws_account_id) is not None
        },
        {
            'type': 'input',
            'name': 'region',
            'message': 'Cloud region (e.g. us-east-1, southcentralus, etc.)',
            'validate': lambda region: re.match(r'^[a-z0-9-]+$', region) is not None
        },
        {
            'type': 'input',
            'name': 'account_id',
            'message': 'Databricks account ID',
            'validate': lambda account_id: re.match(r'^[a-f0-9-]+$', account_id) is not None
        },
        {
            'type': 'list',
            'name': 'language',
            'message': 'What language do you want to use',
            'choices': ['Python', 'Scala'],
            'default': 0
        },
        {
            'type': 'checkbox',
            'name': 'features',
            'message': 'What additional features do you want to use',
            'choices': [
                Choice('system_tables', name='System Tables', enabled=False),
                Choice('ebs_gp3_volumes', name='EBS gp3 Volumes', enabled=False),
                Separator(),
                Choice('dlt_pipeline', name='DLT Pipeline - Autoloader', enabled=False),
            ],
        },
        {
            'type': 'checkbox',
            'name': 'workspaces',
            'message': 'Select the workspaces you want (choose none if you need to customize)',
            'choices': [
                Choice('dev', name='dev', enabled=False),
                Choice('test', name='test', enabled=False),
                Choice('stage', name='stage', enabled=False),
                Choice('prod', name='prod', enabled=False),
                Choice('main', name='main', enabled=True),
            ],
        },
        {
            'type': 'checkbox',
            'name': 'catalogs',
            'message': 'What catalogs do you want to use (choose none if you need to customize)',
            'choices': [
                Choice('dev', name='dev', enabled=True),
                Choice('test', name='test', enabled=False),
                Choice('stage', name='stage', enabled=False),
                Choice('prod', name='prod', enabled=True),
                Choice('main', name='main', enabled=False),
            ],
        },
        {
            'type': 'input',
            'name': 'custom_catalogs',
            'message': 'Enter custom catalog names separated by commas (ex: dev,test,prod)',
            'when': lambda answers: not answers['catalogs'],
            'validate': lambda answer: re.match(r'^[a-z0-9_]+(,[a-z0-9_]+)*$', answer) is not None
        }
    ]

    settings = prompt(questions)

    _run(settings)


def _run(settings: dict):
    """
    Runs the jumpstart generator with the provided settings.
    This function can be called after the interactive prompts
    or with a provided settings dictionary loaded from a JSON file.

    Parameters:
        settings (dict): A dictionary containing the settings for the function.

    Returns:
        None
    """
    # Setup folder to write rendered files to
    if os.path.exists(settings['name']):
        if settings['overwrite']:
            # recursively delete the files and folders at the given path
            shutil.rmtree(settings['name'])
            # print(f"Folder {settings['name']} deleted.")
        else:
            print(f"{settings['name']} already exists. Aborting.")
            return

    os.mkdir(settings['name'])

    # Workspace topology - if no workspaces were selected, then get custom entries next
    if not settings.get('workspaces'):
        # Repeatedly ask for inputting workspaces until done
        settings['workspaces'] = narg_input('Enter a workspace name', 'Add more workspaces?')

    # Catalog structure
    if settings.get('custom_catalogs'):
        settings['catalogs'] = settings['custom_catalogs'].split(',')

    def _tmpl_filter(tmpl_name: str) -> bool:
        """
        Filters out templates that don't match the selected features.
        """
        if 'opt_' in tmpl_name:
            # regex extract the rest of the word after 'opt_' from tmpl_name
            feature = re.search(r'(?<=opt_)[a-z_]+', tmpl_name).group(0)
            if feature not in settings['features']:
                return False
        return True

    # Load the templates
    for tmpl_path in env.list_templates(filter_func=_tmpl_filter):
        # Render the template with the data
        tmpl = env.get_template(tmpl_path)
        output = tmpl.render(settings)
        output_file_path = os.path.join(settings['name'], tmpl_path)

        if 'opt_' in output_file_path:
            # regex remove 'opt_' from output_file_path
            output_file_path = re.sub(r'opt_', '', output_file_path)

        # Create the directories if they don't already exist
        directory_path = os.path.dirname(output_file_path)
        os.makedirs(directory_path, exist_ok=True)

        # print(output)
        with open(output_file_path, 'w', encoding='utf-8') as f:
            f.write(output)

    # Write the settings to a JSON file. This can be used in the future
    # like a snapshot, or preset selections.
    with open(os.path.join(settings['name'], 'settings.json'), 'w', encoding='utf-8') as f:
        json.dump(settings, f, ensure_ascii=False, indent=4)

if __name__ == '__main__':
    main()
