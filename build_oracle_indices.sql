create index qsar_sys_id on qsar_sets(system_id);
create index qsar_cls_id on qsar_sets(class_id);
create index qsar_cmpd_id on qsar_sets(compound_id);
create index qsar_act_id on qsar_sets(action_id);
create index qsar_cit_id on qsar_sets(citation_id);

create index str_qsar on structures(qsar_id);
create index str_smi on structures(smiles_id);

create index param_qsar on qsar_parameters(qsar_id);

create view qsar_master as
    select qsar_id, system, class, compound, action, citation, model, n, r, s
    from qsar_sets a, systems, classes, compounds, actions, citations
    where a.system_id=systems.system_id and a.compound_id=compounds.compound_id
        and a.class_id=classes.class_id and a.action_id=actions.action_id
        and a.citation_id=citations.citation_id;