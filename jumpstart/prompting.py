from InquirerPy import prompt

def narg_input(msg: str, continue_msg: str) -> list[str]:
    """
    Repeatedly ask for inputting workspaces until done.

    :param msg: A string representing the message to display when asking for input.
    :param continue_msg: A string representing the message to display when asking 
        if the user wants to continue.
    :return: A list of strings representing the answers provided by the user.
    """
    answers = []

    while True:
        tmp = prompt([
            {
                'type': 'input',
                'name': 'answer',
                'message': msg,
            },
            {
                'type': 'confirm',
                'name': 'continue',
                'message': continue_msg,
                'default': True
            }
        ])
        answers.append(tmp['answer'].strip())
        if not tmp['continue']:
            break
    return answers
