#! /bin/bash 


function generate_local_tasks()
{
        job_name=$1
	test -f $DIAG_DB || return 1
	sql="select id_job from er_job where name ='$job_name';"
	id_job=$(echo $sql | sqlite3 $DIAG_DB)
	sql="select id_task from er_task where id_job ='$id_job';"
	id_task_list=$(echo $sql | sqlite3 $DIAG_DB)
        task_count=0
        for id_task in $id_task_list; do
            ret_config="#! /bin/bash";
            ret_config+="\n";
	    sql="select name from er_task where id_job ='$id_job' and id_task='$id_task';"
	    task_name=$(echo $sql | sqlite3 $DIAG_DB)
	    sql="select type from er_task where id_job ='$id_job' and id_task='$id_task';"
	    task_type=$(echo $sql | sqlite3 $DIAG_DB)
	    sql="select id_taskparam from er_taskparam where id_task ='$id_task' and id_task='$id_task';"
	    id_taskparam_list=$(echo $sql | sqlite3 $DIAG_DB)
            ret_config+="#\n"
            param_count=0
            for id_taskparam in $id_taskparam_list; do
	        sql="select param_name from er_taskparam where id_taskparam ='$id_taskparam' and id_task='$id_task';"
	        param_name=$(echo $sql | sqlite3 $DIAG_DB)
	        sql="select param_value from er_taskparam where id_taskparam ='$id_taskparam' and id_task='$id_task';"
	        param_value=$(echo $sql | sqlite3 $DIAG_DB)
                uppercase_param=$(echo $param_name | tr '[:lower:]' '[:upper:]')
                ret_config+="$PARAM_PREFIX$uppercase_param=__"$param_name"__"
                ret_config+="\n"
                pcount=$((param_count+1));
                param_count=$pcount
            done
            count=$((task_count+1));
            task_count=$count
            test -f "$OUTPUTDIR/task.$task_name.sh" && echo "Keeping: [$OUTPUTDIR/task.$task_name.sh]" || echo "Generating:  [$OUTPUTDIR/task.$task_name.sh]"
            test -f "$OUTPUTDIR/task.$task_name.sh" || printf "$ret_config" > $OUTPUTDIR/"task."$task_name".sh"
        done
}

function purge_job()
{
        job_name=$1
	test -f $DIAG_DB || return 1
	sql="select id_job from er_job where name ='$job_name';"
	id_job=$(echo $sql | sqlite3 $DIAG_DB)
	sql="select id_task from er_task where id_job ='$id_job';"
	id_task_list=$(echo $sql | sqlite3 $DIAG_DB)
        for id_task in $id_task_list; do
	    sql="select name from er_task where id_job ='$id_job' and id_task='$id_task';"
	    task_name=$(echo $sql | sqlite3 $DIAG_DB)
	    sql="select type from er_task where id_job ='$id_job' and id_task='$id_task';"
	    task_type=$(echo $sql | sqlite3 $DIAG_DB)
	    sql="select id_taskparam from er_taskparam where id_task ='$id_task' and id_task='$id_task';"
	    id_taskparam_list=$(echo $sql | sqlite3 $DIAG_DB)
            for id_taskparam in $id_taskparam_list; do
	        sql="delete from er_taskparam where id_taskparam ='$id_taskparam' and id_job ='$id_job';"
	        echo $sql | sqlite3 $DIAG_DB
            done
	    sql="delete from er_task where id_task ='$id_task';"
	    echo $sql | sqlite3 $DIAG_DB
        done
	sql="delete from er_job where id_job ='$id_job';"
	echo $sql | sqlite3 $DIAG_DB
}

function export_job()
{
        job_name=$1
	test -f $DIAG_DB || return 1
	sql="select id_job from er_job where name ='$job_name';"
	id_job=$(echo $sql | sqlite3 $DIAG_DB)
	sql="select id_task from er_task where id_job ='$id_job';"
	id_task_list=$(echo $sql | sqlite3 $DIAG_DB)
        ret_config="{\"name\": \"$job_name\","
        ret_config+=" \"tasks\": ["
        task_count=0
        for id_task in $id_task_list; do
	    sql="select name from er_task where id_job ='$id_job' and id_task='$id_task';"
	    task_name=$(echo $sql | sqlite3 $DIAG_DB)
	    sql="select type from er_task where id_job ='$id_job' and id_task='$id_task';"
	    task_type=$(echo $sql | sqlite3 $DIAG_DB)
            if [ "$task_count" != "0" ]; then
                ret_config+=", ";
            fi
            ret_config+="{\"name\": \"$task_type\", \"type\": \"$task_type\", \"params\": "
	    sql="select id_taskparam from er_taskparam where id_task ='$id_task' and id_task='$id_task';"
	    id_taskparam_list=$(echo $sql | sqlite3 $DIAG_DB)
            ret_config+="{"
            param_count=0
            for id_taskparam in $id_taskparam_list; do
	        sql="select param_name from er_taskparam where id_taskparam ='$id_taskparam' and id_task='$id_task';"
	        param_name=$(echo $sql | sqlite3 $DIAG_DB)
	        sql="select param_value from er_taskparam where id_taskparam ='$id_taskparam' and id_task='$id_task';"
	        param_value=$(echo $sql | sqlite3 $DIAG_DB)
                if [ "$param_count" != "0" ]; then
                    ret_config+=", ";
                fi
                ret_config+="\"$param_name\": \"$param_value\""
                pcount=$((param_count+1));
                param_count=$pcount
            done
            ret_config+="}"
            ret_config+="}"
            count=$((task_count+1));
            task_count=$count
        done
        ret_config+=" ]"
        ret_config+="}"
        echo $ret_config
}

function edit_job()
{
    echo "Insert job name:"
    read job_name
    id_job=$(uuidgen)
    insert_job $id_job $job_name 
    choice="c"
    while [ "$choice" != "x" ]; do
        echo ""
        echo "-------------"
        echo "x to exit"
        echo "a to add task"
        read choice
        if [ "$choice" = "a" ]; then
            id_task=$(uuidgen)
            echo ""
            echo "Insert task name:"
            read task_name
            echo ""
            echo "Insert task type:"
            read task_type
            insert_task $id_task $id_job $task_name $task_type
            echo ""
            echo "-------------"
            echo "x to exit"
            echo "a to add param"
            read par_choice
            while [ "$par_choice" = "a" ]; do
                echo "Insert Parameter Name:"
                read param_name
                echo ""
                echo "Insert Parameter Value:"
                read param_value
                echo ""
                insert_param $id_task $param_name $param_value
                echo ""
                echo "-------------"
                echo "x to exit"
                echo "a to add param"
                read par_choice
            done
        fi
    done
}

function remote_list_to_local_db()
{
    secure_get ${GET_BACKEND} > ${TMPFILE}
    cat ${TMPFILE} |  python -c 'import sys, json; print json.dumps(json.load(sys.stdin),indent=4)'
    array_len=$(cat ${TMPFILE} | python -c 'import sys, json; print len(json.load(sys.stdin)["playlist"])')
    acount=0;
    while [ "$acount" -lt "$array_len" ]; do
       echo "acount=$acount"
       jsonblock=$(cat ${TMPFILE} | python -c "import sys, json; print json.load(sys.stdin)['playlist'][$acount]")
       item_id=$(cat ${TMPFILE} | python -c "import sys, json; print json.load(sys.stdin)['playlist'][$acount]['id']")
       item_title=$(cat ${TMPFILE} | python -c "import sys, json; print json.load(sys.stdin)['playlist'][$acount]['title']")
       echo "ID: $item_id, TITLE: $item_title"
       appo=$((acount++))
       id_content=$(uuidgen)
       sql="insert into rc_content (id_content, code, title, content) values ('$id_content', '$item_id', '$item_title', NULL);"
       test -f $DIAG_DB || return 1
       echo $sql | sqlite3 $DIAG_DB
    done 
}

function remote_to_local_db()
{
    code=$1
    secure_get ${GET_BACKEND}/$code > ${TMPFILE}
    remote_id=$(cat ${TMPFILE} | python -c 'import sys, json; print json.load(sys.stdin)["id"]') 
    title=$(cat ${TMPFILE} | python -c 'import sys, json; print json.load(sys.stdin)["title"]') 
    content=$(cat ${TMPFILE} | python -c 'import sys, json; print json.load(sys.stdin)["content"]') 
    sql="insert into rc_content (id_content, code, title, content) values ('$remote_id', '$code', '$title', '$content');"
    test -f $DIAG_DB || return 1
    echo $sql | sqlite3 $DIAG_DB
}

function insert_param()
{
        id_taskparam=$(uuidgen)
        id_task=$1
        param_name=$2
        param_value=$3
	sql="insert into er_taskparam (id_taskparam, id_task, param_name, param_value) values ('$id_taskparam', '$id_task', '$param_name', '$param_value');"
	test -f $DIAG_DB || return 1
	echo $sql | sqlite3 $DIAG_DB
}

function insert_job()
{
        id_job=$1
        name=$2
	sql="insert into  er_job (id_job, name) values ('$id_job', '$name');"
	test -f $DIAG_DB || return 2
	echo $sql | sqlite3 $DIAG_DB
}

function list_tasks()
{
    sql="select name from er_task;"
    job_list=$(echo $sql | sqlite3 $DIAG_DB)
    echo $job_list
}

function list_jobs()
{
    sql="select name from er_job;"
    job_list=$(echo $sql | sqlite3 $DIAG_DB)
    echo $job_list
}

function insert_task()
{
        id_task=$1
        id_job=$2
        name=$3
        vtype=$4
	sql="insert into er_task (id_task, id_job, name, type) values ('$id_task', '$id_job', '$name', '$vtype');"
	test -f $DIAG_DB || return 2
	echo $sql | sqlite3 $DIAG_DB
}

function create_db()
{
	sql_job="create table er_job (id_job text, name text, comment text);"
	sql_task="create table er_task (id_task text, id_job text, name text, type text);"
	sql_param="create table er_taskparam (id_taskparam text, id_task text, param_name text, param_value text);"
	echo $sql_job | sqlite3 $DIAG_DB
	echo $sql_task | sqlite3 $DIAG_DB
	echo $sql_param | sqlite3 $DIAG_DB

	sql_content="create table rc_content (id_content text, code text, title text, content text);"
	echo $sql_content | sqlite3 $DIAG_DB
}


