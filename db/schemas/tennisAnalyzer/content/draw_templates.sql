set feedback off
set define off

prompt Loading DRAW_TEMPLATES...
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('RR8-F', 0, 0, 8, 'main round of 8 (ATP Finals)');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('RR12', 0, 0, 12, 'main round of 12 (Laver Cup)');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('R128', 0, 0, 128, 'main round of 128');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('RR18', 0, 0, 18, 'main round of 18 (United Cup)');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('R28', 0, 0, 28, 'main round of 28');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('RR32', 0, 0, 32, 'main round of 32 (with round robin)');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('R48', 0, 0, 48, 'main round of 48');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('R56', 0, 0, 56, 'main round of 56');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('R64', 0, 0, 64, 'main round of 64');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('RR8-NG', 0, 0, 8, 'main round of 8 (Next Gen)');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('R96', 0, 0, 96, 'main round of 96');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('R32-Q12', 0, 0, 32, 'main round of 32, qual round 12');
insert into DRAW_TEMPLATES (id, delta_hash, batch_id, draw_size, description)
values ('R32-Q8', 0, 0, 32, 'main round of 32, qual round 8');
commit;
prompt 13 records loaded

set feedback on
set define on
prompt Done
