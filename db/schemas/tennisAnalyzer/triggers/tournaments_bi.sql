create or replace trigger tournaments_bi
                          before insert on tournaments
                          for each row
begin
    if :new.ID is null then
        select seq_tennis.nextval
        into :new.ID
        From Dual;
    end if;
end tournaments_bi;
/
