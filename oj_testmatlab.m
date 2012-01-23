function [row] = oj_testmatlab(x1, x2)

dispf('If we reached here, then matlab can start correctly.');

row = bundle(x1,x2);
row.mult = x1*x2;

delay = mod(urandom(), 30);
dispf('WAITING FOR %d SECONDS RANDOMLY...', delay);
pause(delay); % WAIT 

dispf('EXITING, NO ERROR...');

