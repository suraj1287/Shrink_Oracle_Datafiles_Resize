sqlplus -s /nolog <<EOF
CONNECT sys/sys as sysdba
create or replace procedure FN_DATA_RESIZE(v_file_name varchar2,v_file_size number)
as
v_count number;
begin
v_count:=100;
    for i in 1..1000 loop
    execute immediate 'alter database datafile '''||v_file_name||''' resize '||to_char(v_file_size-v_count*i)||'M ';
    end loop;
    exception when others then
    null;
end;
/

declare
v_file_name varchar2(500);
v_actual_size number; 
v_after_size number; 
cursor cur_resize is 
select df.FILE_NAME ,round(sum(df.bytes)/(1024*1024)) as file_size
from dba_data_files df
group by df.file_name ; 
begin
for v_cur_resize in cur_resize
 loop
 v_file_name:=v_cur_resize.file_name;
 v_actual_size:=v_cur_resize.file_size;    
 FN_DATA_RESIZE(v_file_name,v_actual_size);
 select round(sum(df.bytes)/(1024*1024)) into v_after_size from dba_data_files df where df.file_name=v_file_name;   
 dbms_output.put_line('FILE NAME '||v_file_name||' BEFORE RESIZE '||v_actual_size||'  AND AFTER RESIZING '||v_after_size);
 end loop;   
end;
/
EXIT;
EOF