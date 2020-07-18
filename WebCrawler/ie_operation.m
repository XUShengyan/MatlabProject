ie=actxserver('internetexplorer.application');
ie.Navigate('https://www.baidu.com/');
while ~strcmp(ie.readystate,'READYSTATE_COMPLETE')
pause(0.01)
end
ie.visible = 1;
SearchItem = ie.document.body.getElementsByClassName('s_ipt').item(0);
SearchItem.value = '¥Ú∆÷«≈≥Ã–Ú‘±';
ButtonItem = ie.document.body.getElementsByClassName('bg s_btn').item(0);
ButtonItem.click