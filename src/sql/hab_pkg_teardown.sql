begin
    execute immediate 'drop package PKG_ALTERATION_BOOK';
exception
when others then
    null;
end;
/
