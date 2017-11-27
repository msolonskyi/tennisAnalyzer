create or replace trigger players_bi
                          before insert on players
                          for each row
begin
    if :new.ID is null then
        select seq_tennis.nextval
        into :new.ID
        From Dual;
    end if;
end players_bi;
/
