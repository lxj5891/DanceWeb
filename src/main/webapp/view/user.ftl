<script type="text/javascript" charset="utf-8">
    var ctx = "/";
    var _csrf = "";
</script>

<link rel="stylesheet" type="text/css" href="/stylesheets/default.css">
<script type="text/javascript" src="/vendor/jquery/jquery-1.10.2.js"></script>
<script type="text/javascript" src="/vendor/easyui/jquery.easyui.min.js"></script>
<script type="text/javascript" src="/vendor/easyui/locale/easyui-lang-zh_CN.js"></script>
<link rel="stylesheet" type="text/css" href="/vendor/easyui/themes/gray/easyui.css" id="swicth-style">
<link rel="stylesheet" type="text/css" href="/vendor/easyui/themes/icon.css">
<link rel="stylesheet" href="/vendor/easyui/themes/icon.css" type="text/css"/>
<script type="text/javascript" src="/javascripts/easyui-extend.js" charset="utf-8"></script>
<script src="/vendor/uploadify/jquery.uploadify.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/vendor/uploadify/uploadify.css">

<script type="text/javascript">
var $user_datagrid;
var editRow = undefined;
var $user_search_form;
$(function () {


    //数据列表
    $user_datagrid = $('#user_datagrid').datagrid({
        url: '/user/list',
        fit: true,
        pagination: true,//底部分页
        pagePosition: 'bottom',//'top','bottom','both'.
        fitColumns: false,//自适应列宽
        striped: true,//显示条纹
        pageSize: 20,//每页记录数
        singleSelect: false,//单选模式
        rownumbers: true,//显示行数
        checkbox: true,
        nowrap: false,
        border: false,
        remoteSort: false,//是否通过远程服务器对数据排序
        sortName: 'id',//默认排序字段
        sortOrder: 'desc',//默认排序方式 'desc' 'asc'
        idField: 'id',
        frozenColumns: [
            [
                {field: 'ck', checkbox: true}
            ]
        ],
        columns: [
            [
                {field: 'id', title: '主键', hidden: true, sortable: true, align: 'right', width: 80},
                {field: 'username', title: '用户名', width: 100, editor: {type: 'validatebox'} },
                {field: 'password', title: '密码', width: 100, editor: {type: 'validatebox'} },
                {field: 'email', title: '邮箱', width: 100, editor: {type: 'validatebox'} } ,
                {field: 'valid', title: '状态', width: 100, editor: {type: 'validatebox'} } ,
                {field: 'createat', title: '创建时间', width: 100, editor: {type: 'validatebox'} } ,
                {field: 'createby', title: '创建者', width: 100, editor: {type: 'validatebox'} } ,
                {field: 'updateat', title: '', width: 100, editor: {type: 'validatebox'} } ,
                {field: 'updateby', title: '', width: 100, editor: {type: 'validatebox'} }
            ]
        ],
        onDblClickRow: function (rowIndex, rowData) {
            if (editRow != undefined) {
                eu.showMsg("请先保存正在编辑的数据！");
                //结束编辑 自动保存
                //$user_datagrid.datagrid('endEdit', editRow);
            } else {
                $(this).datagrid('beginEdit', rowIndex);
                editRow = rowIndex;
                $(this).datagrid('unselectAll');
            }
        },
        onAfterEdit: function (rowIndex, rowData, changes) {
            $.messager.progress({
                title: '提示信息！',
                text: '数据处理中，请稍后....'
            });
            var inserted = $user_datagrid.datagrid('getChanges', 'inserted');
            var updated = $user_datagrid.datagrid('getChanges', 'updated');
            if (inserted.length < 1 && updated.length < 1) {
                editRow = undefined;
                $(this).datagrid('unselectAll');
                return;
            }
            $.post('/user/save', rowData,
                    function (data) {
                        $.messager.progress('close');
                        if (data.code == 1) {
                            $user_datagrid.datagrid('acceptChanges');
                            editRow = undefined;
                            editRowData = undefined;
                            $user_datagrid.datagrid('reload');
                            eu.showMsg(data.msg);
                        } else if ((data.code == 2)) {//警告信息
                            $.messager.alert('提示信息！', data.msg, 'warning', function () {
                                $user_datagrid.datagrid('beginEdit', editRow);
                                if (data.obj) {
                                    var validateEdit = $user_datagrid.datagrid('getEditor', {index: rowIndex, field: data.obj});
                                    $(validateEdit.target).focus();
                                }
                            });
                        } else {
                            $user_datagrid.datagrid('rejectChanges');
                            $user_datagrid.datagrid('beginEdit', editRow);
                            eu.showAlertMsg(data.msg, 'error');
                        }
                    }, 'json');
        },
        onLoadSuccess: function () {
            $(this).datagrid('clearSelections');//取消所有的已选择项
            $(this).datagrid('unselectAll');//取消全选按钮为全选状态
            editRow = undefined;
        },
        onRowContextMenu: function (e, rowIndex, rowData) {
            e.preventDefault();
            $(this).datagrid('unselectAll');
            $(this).datagrid('selectRow', rowIndex);
            $('#user_menu').menu('show', {
                left: e.pageX,
                top: e.pageY
            });
        }
    }).datagrid("showTooltip");
    ;
});

//新增
function add() {
    if (editRow != undefined) {
        //eu.showMsg("请先保存正在编辑的数据！");
        $user_datagrid.datagrid('endEdit', editRow);
    } else {
        cancelSelect();
        var row = {id: ''};
        $user_datagrid.datagrid('appendRow', row);
        editRow = $user_datagrid.datagrid('getRows').length - 1;
        $user_datagrid.datagrid('selectRow', editRow);
        $user_datagrid.datagrid('beginEdit', editRow);
        var rowIndex = $user_datagrid.datagrid('getRowIndex', row);//返回指定行的索引
        var sortEdit = $user_datagrid.datagrid('getEditor', {index: rowIndex, field: 'orderNo'});
    }
}

//编辑
function edit() {
    //选中的所有行
    var rows = $user_datagrid.datagrid('getSelections');
    //选中的行（第一次选择的行）
    var row = $user_datagrid.datagrid('getSelected');
    if (row) {
        if (rows.length > 1) {
            row = rows[rows.length - 1];
            eu.showMsg("您选择了多个操作对象，默认操作最后一次被选中的记录！");
        }
        if (editRow != undefined) {
            eu.showMsg("请先保存正在编辑的数据！");
            //结束编辑 自动保存
            //$user_datagrid.datagrid('endEdit', editRow);
        } else {
            editRow = $user_datagrid.datagrid('getRowIndex', row);
            $user_datagrid.datagrid('beginEdit', editRow);
            $user_datagrid.datagrid('unselectAll');
        }
    } else {
        if (editRow != undefined) {
            eu.showMsg("请先保存正在编辑的数据！");
        } else {
            eu.showMsg("请选择要操作的对象！");
        }
    }
}

//保存
function save(rowData) {
    if (editRow != undefined) {
        //结束编辑 自动保存
        $user_datagrid.datagrid('endEdit', editRow);
    } else {
        eu.showMsg("请选择要操作的对象！");
    }
}

//取消编辑
function cancelEdit() {
    cancelSelect();
    $user_datagrid.datagrid('rejectChanges');
    editRow = undefined;
    editRowData = undefined;
}
//取消选择
function cancelSelect() {
    $user_datagrid.datagrid('unselectAll');
}

//删除
function del() {
    var rows = $user_datagrid.datagrid('getSelections');
    if (rows.length > 0) {
        if (editRow != undefined) {
            eu.showMsg("请先保存正在编辑的数据！");
            return;
        }
        $.messager.confirm('确认提示！', '您确定要删除当前选中的所有行？', function (r) {
            if (r) {
                var ids = new Array();
                $.each(rows, function (i, row) {
                    ids[i] = row.id;
                });
                $.ajax({
                    url: '/user/delete',
                    type: 'post',
                    data: {ids: ids},
                    traditional: true,
                    success: function (data) {
                        if (data.code == 1) {
                            $user_datagrid.datagrid('clearSelections');//取消所有的已选择项
                            $user_datagrid.datagrid('load');	// reload the user data
                            eu.showMsg(data.msg);//操作结果提示
                        } else {
                            eu.showAlertMsg(data.msg, 'error');
                        }
                    }
                });
            }
        });
    } else {
        eu.showMsg("请选择要操作的对象！");
    }
}

//搜索
function search() {
    $user_datagrid.datagrid('load', $.serializeObject($user_search_form));
}
</script>
<div class="easyui-layout" fit="true" style="margin: 0px;border: 0px;overflow: hidden;width:100%;height:100%;">

    <div data-options="region:'center',split:false,border:false"
         style="padding: 0px; height: 100%;width:100%; overflow-y: hidden;">

        <div id="user_menu" class="easyui-menu" style="width:120px;display: none;">
            <div onclick="add();" data-options="iconCls:'icon-add'">新增</div>
            <div onclick="edit();" data-options="iconCls:'icon-edit'">编辑</div>
            <div onclick="del();" data-options="iconCls:'icon-remove'">删除</div>
        </div>


        <div id="user_toolbar">
            <div style="margin-bottom:5px">
                <a href="#" class="easyui-linkbutton" iconCls="icon-add" plain="true" onclick="add()">新增</a>
                <a href="#" class="easyui-linkbutton" iconCls="icon-edit" plain="true" onclick="edit()">编辑</a>
                <a href="#" class="easyui-linkbutton" iconCls="icon-remove" plain="true" onclick="del()">删除</a>
                <a href="#" class="easyui-linkbutton" iconCls="icon-save" plain="true" onclick="save()">保存</a>
                <a href="#" class="easyui-linkbutton" iconCls="icon-undo" plain="true" onclick="cancelEdit()">取消编辑</a>
                <a href="#" class="easyui-linkbutton" iconCls="icon-undo" plain="true" onclick="cancelSelect()">取消选中</a>
            </div>
        </div>
        <table id="user_datagrid" toolbar="#user_toolbar"></table>

    </div>
</div>