from jumpstart.prompting import narg_input

def test_narg_input(mocker):
    mocker.patch('jumpstart.prompting.prompt', side_effect=[{'answer': 'test1', 'continue': True}, {'answer': 'test2', 'continue': False}])
    msg = 'Enter something:'
    continue_msg = 'Do you want to continue?'
    expected_answers = ['test1', 'test2']
    actual_answers = narg_input(msg, continue_msg)
    assert actual_answers == expected_answers
