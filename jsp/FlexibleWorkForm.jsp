<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%-- <%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%> --%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    select[name*="Temp"]{display:none;}
    select[disabled=""]{background-color:#DDDDDD;}
    .calendar input[disabled="disabled"]{background-color:#DDDDDD;}
    .calendar input[disabled]{background-color:#DDDDDD;}
    select[class^='sHM']{min-width:60px; padding-right: 0px;}
/*     .sHM_1{min-width:60px; padding-right: 0px;} */
    .formDetailDiv{min-height:100px;} 
    .tableW700{width:700px !important;}
</style>
    
    
<c:set var="titleUseYn" value="${empty E_RESULT_OLD.PERNR || E_RESULT_OLD.PERNR eq '00000000' || E_RESULT_OLD.PERNR eq '' ? 'N': 'Y'}" />

<script>
var param = {
        "ACTION" : "",
        "changeFlag" : "",
        "initYn" : "N", //근무세부 유형 초기화 여부 
        "titleUseYn" : "", //변경전,변경후  보이면 Y 
        "updateOldYn" : "", //데이터 변경여부(변경된 경우 Y)
        "endApplyYn" : "" == 'X' ? "Y" : "N", //결제종료인 경우 Y
        "zlcty" : "", //근무유형
        "zlcod" : "",  //세부유형      
        "cancelYn" : "", 
        "ars_min" : "",  //근무시간(최소)
        "ars_max" : "",  //근무시간(최대)
        "wostd" : "",    //주간근무시간
        "msgCode" : "",
        "message" : ""
} // 유형별 화면 셋팅 전역변수

$(document).ready(function(){
	param.ACTION = "${reqParam.ACTION}";
	
	// SAP에러인 경우 
    if("S000" != "${result.MSGCODE}"){
        cfAlertMsg("${result.MESSAGE}");
        
        if(param.ACTION == "UPDATE" || param.ACTION == "ENDAPPLY"){//변경신청 또는 종료신청하는 경우 - 상세조회로... 
	        var iFLWNO = $("#iFLWNO").val();
	        var iSEQNR = $("#iSEQNR").val();
	        $("#aList tbody tr").each(function(){
	        	if($(this).find("input[name=oFLWNO]").val() == iFLWNO && $(this).find("input[name=oSEQNR]").val() == iSEQNR){
	        	    next = "N";
	        	    $(this).trigger("click")
	        	    return false;
	            }
	        })
        }
    }else{
	    markPayNFile(param.ACTION)
    }
})

// 세부유형 조회 
function fn_formDetailAjax(urlVal, param){
    if(param.changeFlag == "" ){
        return alert("설정값이 잘못되었습니다");
    }
    
    var targetDiv = "#formDetailDiv_"+param.changeFlag;
    $(targetDiv).empty();
    $.ajax({
        url: urlVal,
        type: "post",
        dataType: "html",
        data : param ,   
        async: true,
        success:function(result) {
            $(targetDiv).append(result);
        },
        error : function(request, status, error) {
            cfAlertMsg("오류가 발생하였습니다.");
        },
        complete : function(){
	        next = "N";
        }
    }).always(function(){
        next = "N";
    })
}

function markPayNFile(actionType){
	if("DETAIL" == actionType || "S000" != "${result.MSGCODE}"){
	    $(".file_attach").find(".btn").hide()
	    $("#btn_approval").hide()
	    $("textarea").prop("disabled",true);
	}else {
	    $(".file_attach").find(".btn").show()
	    $("#btn_approval").show()
	    $("textarea").prop("disabled",false);
	}

	$.fn_call_approval_file($("#iZWFKEY").val());//파일첨부
    $.fn_call_approval_line($("#iSEQNR").val(), $("#iBEGDA").val().replace(/\./gi, ""), $("#iENDDA").val().replace(/\./gi, "")); //결재선
}

function markApNote(param){
	var formCommDiv = "#formCommDiv_"+param.changeFlag;
	var formDetailDiv = "#formDetailDiv_"+param.changeFlag;
	
    if(param.ACTION == "DETAIL" || param.initYn == "N"){
	    var vAPNOTE = $(formCommDiv).find(".vAPNOTE").val();
		$(formDetailDiv).find(".oAPNOTE").val(vAPNOTE);
    }else{
		$(formDetailDiv).find(".oAPNOTE").val("");
    }

// 	$("#content_form .oAPNOTE").prop("disabled", false);//신청사유
    
// 	if("DETAIL" == actionType){
// 	    $(".formDiv .oAPNOTE").prop("disabled", true);
// 	    var vENDDAFLG = $(formCommDiv).find(".vENDDAFLG").val();
// 	    if(vENDDAFLG == "X"){
// 	    	$(formDetailDiv).find(".oAPNOTE_TH").text("종료신청 사유")
// 	    }
// 	}else {
// 	    $("#formDetailDiv_before .oAPNOTE").prop("disabled",true);
// 	}
}

// function appendOptions(dailyTr, type, changeFlag, optionArr){
function appendOptions(type, changeFlag, optionArr){
	if(type == "" ){
		return alert("선택옵션이 잘못되엇습니다");
	}
	
// 	console.log("appendOptions=>",dailyTr, type, optionArr)
	if(type == "sTMDTY"){
		var formCommDiv = "#formCommDiv_"+ changeFlag;
		var selector = "#"+type+"_"+changeFlag;
		$(formCommDiv).find(selector).empty();
		$(formCommDiv).find(selector).append("<option value=''>선택하세요</option>");
		for(var i=0; i<optionArr.length; i++){
			$(formCommDiv).find(selector).append(optionArr[i]);
		}
	}else{
		var formDetailDiv = "#formDetailDiv_"+ changeFlag;
		var selector = "."+type;
		$(formDetailDiv).find(selector).empty();
		$(formDetailDiv).find(selector).append("<option value=''></option>");
		for(var i=0; i<optionArr.length; i++){
			$(formDetailDiv).find(selector).append(optionArr[i]);
		}
	}
}

function getSelectOptions(type, changeFlag, zlcty, zlcod){
// 	console.log("getSelectOptions=>",type, changeFlag, zlcty, zlcod)
    var optionArr = new Array();
	if(type == ""){
		return optionArr;
	}
    var selectorTemp = $("#formCommDiv_"+changeFlag).find("."+type+"_Temp");
    
    selectorTemp.find("option").each(function(){
        var option_zlcty = $(this).attr("zlcty");
        var option_zlcod = $(this).attr("zlcod");
        
//      	console.log("type:"+ type+ ",option_zlcty=>"+option_zlcty + ", option_zlcod:"+option_zlcod)
        if(type == "sFAMTY" && $(this).val() != ""){
            optionArr.push($(this).clone());
        }else if( type == "sTMDTY"){
            if(option_zlcty == zlcty){
                optionArr.push($(this).clone());
            }
        }else if( zlcty == "20" || zlcty == "80"){
        	if(option_zlcty == zlcty){
	            optionArr.push($(this).clone());
        	}
        }else{
	        if(option_zlcty == zlcty && option_zlcod == zlcod){
	            optionArr.push($(this).clone());
            }
        }
    })
    return optionArr;
}

function markWeeklyWorkTime(param){
	var formCommDiv = "#formCommDiv_"+param.changeFlag;
	var formDetailDiv = "#formDetailDiv_"+param.changeFlag;

	var workDayWeek = 0;    //주간근무일수
    var workTimeWeek = 0;   //주간근무시간
// 	$(formDetailDiv).find(".dailyTr").each(function(idx){
// 		var sZAT = $(this).find(".sZAT option:selected").val();
//         var stH = nvl($(this).find("select[name=sBEZ_C] option:selected").val(), "");
//         var stM = nvl($(this).find("select[name=sBEZ_M] option:selected").val(), "");
//         var edH = nvl($(this).find("select[name=sENZ_C] option:selected").val(), "");
//         var edM = nvl($(this).find("select[name=sENZ_M] option:selected").val(), "");
        
//         var stH1 = nvl($(this).find("select[name=sBEZ_C_1] option:selected").val(), "");
//         var stM1 = nvl($(this).find("select[name=sBEZ_M_1] option:selected").val(), "");
//         var edH1 = nvl($(this).find("select[name=sENZ_C_1] option:selected").val(), "");
//         var edM1 = nvl($(this).find("select[name=sENZ_M_1] option:selected").val(), "");
        
// 	    var time  = 0;
// 		var time1 = 0;
// 	    if(sZAT == "5")	{
// 	        if(getRestTime(stH, stM, edH, edM) == 0){
// 	            time = Number(getWorkTime(this, param));
// 	        }
// 	        if(getRestTime(stH1, stM1, edH1, edM1) == 0){
// 	            time1 = Number(getWorkTime1(this, param));
// 	        }
// 	    }else {
// 	        time = Number(getWorkTime(this, param));
// 	        time1 = Number(getWorkTime1(this, param));
// 	    }
//         workDayWeek += (sZAT != "" && sZAT != "3") ? 1 : 0;
//         workTimeWeek += (time + time1);
// 	})

    $(formDetailDiv).find(".dailyTr").each(function(idx){
    	var sZAT = $(this).find(".sZAT option:selected").val();
    	
    	var time = Number($(this).find(".oARS").val());
    	time = isNaN(time) ? 0 : time;
    	var time1 = Number($(this).find(".oARS_1").val());
    	time1 = isNaN(time1) ? 0 : time1;
    	
    	workDayWeek += (sZAT != "" && sZAT != "3") ? 1 : 0;
    	workTimeWeek += (time + time1);
    })
    
	console.log(workDayWeek.toFixed(2), workTimeWeek.toFixed(2))
	$(formCommDiv).find(".workDayWeek input[type=text]").val(workDayWeek.toFixed(2)) //주간근무일수
    $(formCommDiv).find(".workTimeWeek input[type=text]").val(workTimeWeek.toFixed(2)) //주간육아시간
	
}

function getTimeObj(dailyTr, param){
    var timeObj = new Object();
    timeObj.sZAT = $(dailyTr).find(".sZAT").val();
    timeObj.sH = $(dailyTr).find(".sBEZ_C").val();
    timeObj.sM = $(dailyTr).find(".sBEZ_M").val();
    timeObj.eH = $(dailyTr).find(".sENZ_C").val();
    timeObj.eM = $(dailyTr).find(".sENZ_M").val();
    
    return timeObj;
}

function getCalcEndTime(sH, sM, wTime){// 시작시간(str), 시작분(str), 근무시간(num)  
    var timeObj = new Object();
    timeObj.eH = '';
    timeObj.eM = sM;
    console.log("getCalcEndTime=>", sH, sM, wTime)
    if(sH == ''){
    	return timeObj;
    }
    
    if(Number(sH)<=12){ // 점심시간 12시 이전에는 점심시간 한시간 차감
        if(sH == '12' && sM == '30'){
        	timeObj.eH = (Number(sH) + wTime).toString();
        }else{
	    	timeObj.eH = (Number(sH) + wTime+1).toString();
        }
    }else {
    	timeObj.eH = (Number(sH) + wTime).toString();
    }
    return timeObj;
}

function setWorkTime(dailyTr, time){
    time = Number(time) == 0 ? "" : time;	
    $(dailyTr).find(".oARS").val(time)
}

function setWorkTime1(dailyTr, time1){
	time1 = Number(time1) == 0 ? "" : time1;	
    $(dailyTr).find(".oARS_1").val(time1)
}

// 근무시간 셋팅
function getWorkTime(dailyTr, param){
    var time = 0.00;
    var idx = $(dailyTr).index();

    var sZAT = $(dailyTr).find(".sZAT option:selected").val();
	if(param.ACTION =="APPLY" || param.ACTION =="UPDATE"){
	    if(sZAT == "4"){
	    	time = "0.00";
	    }else{
		    var stH = nvl($(dailyTr).find("select[name=sBEZ_C] option:selected").val(), "");
			var stM = nvl($(dailyTr).find("select[name=sBEZ_M] option:selected").val(), "");
			var edH = nvl($(dailyTr).find("select[name=sENZ_C] option:selected").val(), "");
			var edM = nvl($(dailyTr).find("select[name=sENZ_M] option:selected").val(), "");
			var suiChk = $(dailyTr).find(".oSUI").prop("checked");
			time = calcWorkTime(stH, stM, edH, edM, param.zlcty, suiChk);
	    }
	}else {
		if(sZAT == "4"){
            time = "0.00";
        }else{
		    time = $(dailyTr).parents(".formDiv").find("#formCommDiv_"+param.changeFlag).find(".vARS0"+(idx+1)).val();
        }
	}

//     $(dailyTr).find(".oARS").val(time)
	 
    return time;
}

// 근무시간 셋팅
function getWorkTime1(dailyTr, param){
    var time = 0.00;
    var idx = $(dailyTr).index();

    if(param.zlcty != "80"){
    	return time;
    }
    
    var sZAT = $(dailyTr).find(".sZAT option:selected").val();
	if(param.ACTION =="APPLY" || param.ACTION =="UPDATE" ){
		if(sZAT == "4"){
            time = "0.00";
        }else{
		    var stH = nvl($(dailyTr).find("select[name=sBEZ_C_1] option:selected").val(), "");
			var stM = nvl($(dailyTr).find("select[name=sBEZ_M_1] option:selected").val(), "");
			var edH = nvl($(dailyTr).find("select[name=sENZ_C_1] option:selected").val(), "");
			var edM = nvl($(dailyTr).find("select[name=sENZ_M_1] option:selected").val(), "");
			time = calcWorkTime(stH, stM, edH, edM);
        }
	}else {
		if(sZAT == "4"){
            time = "0.00";
        }else{
		    time = $(dailyTr).parents(".formDiv").find("#formCommDiv_"+param.changeFlag).find(".vARS0"+(idx+1)+"_1").val();
        }
	}

//     $(dailyTr).find(".oARS_1").val(time)
	 
    return time;
}

function fn_save(saveType){
     // 결재요청시 확인
		    console.log("saveType=>", saveType)		 
	 if(saveType == "REQUEST" || saveType == "REQUPDATE" || saveType == "REQEND"){
		 if(saveChk_Comm(saveType)){  //결제요청시 체크사항(유형 공통)
			 return;
		 }
		 if(saveType == "REQUEST" || saveType == "REQUPDATE"){
		     if(isIncorrectSelect()){ // 일별 근무구분 및 시간 체크
		         return ;
		     }
		     if(saveChk_byType()){ //근무유형별 근무시간 체크 
		         return;
		     }
		     if(saveType == "REQUPDATE"){
		    	 if(!checkChange()){ // 변경여부 체크 (변경시 true)
					 alert("변경사항이 없습니다.")
	                 return;
	             }
		     }
		 } else if (saveType == "REQEND"){
			 if(isENDDADiff()){ // 종료일자 변경여부 체크
				 alert("변경사항이 없습니다")
                 return ;
             }
		 }
			 
	 }
	
	setSaveForm(saveType);
    var saveForm= $("#saveForm")[0];
    var formData = new FormData(saveForm);

    $.ajax({
        async : false , 
        url      : "/ess/pa.FlexibleSaveAjax.do",
        type     : "POST",
        enctype: "multipart/form-data",
        processData:false,  //important
        contentType:false,
        cache : false ,
        dataType : "json",
        data : formData ,  
        success  : function(response) {
            if (response.MSGCODE == "S000") {
                if (saveType == "REQUEST" || saveType == "REQUPDATE") {
                    cfAlertMsg("결재 요청되었습니다.");
                } else if (saveType == "DELETE") {
                    cfAlertMsg("삭제 되었습니다.");
                } else if ( saveType == "REQCANCEL"){
                    cfAlertMsg("결재 회수되었습니다.");
                } else if ( saveType == "REQEND"){
                    cfAlertMsg("종료신청 되었습니다.");
                } 
                
                location.href = "./pa.selectFlexibleWork.do";
                
            } else {
                cfAlertMsg(response.MESSAGE);
                
            }
        },
        error    : function(jqXHR, textStatus, errorThrown) {
            cfAlertMsg("code : " + jqXHR.status + "\n" + "message : " + jqXHR.responseText + "\n" + "error : " + errorThrown);
        },
        complete : function(){
            next = "N";
        }
    }).always(function(){
    	next = "N";
    })
}

function checkChange(){
	var flag = false;  
	
    if(nvl($("#iCANFLG_after:checked").val(), "") == 'X' ){  //취소여부
    	return flag = true ; 
    }
    
    if(nvl($("input[name*=oBEGDA_]").eq(0).val(), "") != nvl($("input[name*=oBEGDA_]").eq(1).val(), "")){     // 시작일
    	return flag = true ; 
    }
    
    if(nvl($("input[name*=oENDDA_]").eq(0).val(), "") != nvl($("input[name*=oENDDA_]").eq(1).val(), "")){     // 종료일
    	return flag = true ; 
    }

    if(nvl($(".sFLWTY_Form").eq(0).val(), "") != nvl($(".sFLWTY_Form").eq(1).val(), "")){     // 근무유형
    	return flag = true ; 
    }
    
    if(nvl($(".sTMDTY_Form").eq(0).val(), "") != nvl($(".sTMDTY_Form").eq(1).val(), "")){     // 세부유형
    	return flag = true ; 
    }
    
    // 월화수목금 체크(근무구분, 시작, 종료, 근무시간, 식사포함)
    var dailyTr_before = $(".timeSelectDiv").eq(0).find('.dailyTr');
    var dailyTr_after = $(".timeSelectDiv").eq(1).find('.dailyTr');
    $(dailyTr_before).each(function(idx){
        if(nvl($(this).find('.sZAT').val(), "") != nvl($(dailyTr_after).eq(idx).find('.sZAT').val(), "")) {
        	flag = true ; 
        	return false;   	
        } else if (nvl($(this).find('select[name=sBEZ_C]').val(), "") != nvl($(dailyTr_after).eq(idx).find('select[name=sBEZ_C]').val(), "")){
        	flag = true ; 
        	return false;   	
        } else if (nvl($(this).find('select[name=sBEZ_C_1]').val(), "") != nvl($(dailyTr_after).eq(idx).find('select[name=sBEZ_C_1]').val(), "")){
            flag = true ; 
            return false;       
        }else if (nvl($(this).find('select[name=sBEZ_M]').val(), "") != nvl($(dailyTr_after).eq(idx).find('select[name=sBEZ_M]').val(), "")){
            flag = true ; 
            return false;       
        } else if (nvl($(this).find('select[name=sBEZ_M_1]').val(), "") != nvl($(dailyTr_after).eq(idx).find('select[name=sBEZ_M_1]').val(), "")){
            flag = true ; 
            return false;       
        } else if (nvl($(this).find('select[name=sENZ_C]').val(), "") != nvl($(dailyTr_after).eq(idx).find('select[name=sENZ_C]').val(), "")){
            flag = true ; 
            return false;       
        } else if (nvl($(this).find('select[name=sENZ_C_1]').val(), "") != nvl($(dailyTr_after).eq(idx).find('select[name=sENZ_C_1]').val(), "")){
            flag = true ; 
            return false;       
        } else if (nvl($(this).find('select[name=sENZ_M]').val(), "") != nvl($(dailyTr_after).eq(idx).find('select[name=sENZ_M]').val(), "")){
            flag = true ; 
            return false;       
        } else if (nvl($(this).find('select[name=sENZ_M_1]').val(), "") != nvl($(dailyTr_after).eq(idx).find('select[name=sENZ_M_1]').val(), "")){
            flag = true ; 
            return false;       
        } else if (nvl($(this).find('.oARS').val(), "") != nvl($(dailyTr_after).eq(idx).find('.oARS').val(), "")){
            flag = true ; 
            return false;       
        } else if (nvl($(this).find('.oARS_1').val(), "") != nvl($(dailyTr_after).eq(idx).find('.oARS_1').val(), "")){
            flag = true ; 
            return false;       
        } else if (nvl($(this).find('.oSUI').val(), "") != nvl($(dailyTr_after).eq(idx).find('.oSUI').val(), "")){
            flag = true ; 
            return false;       
        }
    })
    
    // 변경사유
    if(nvl($(".oAPNOTE").eq(0).val(), "") != nvl($(".oAPNOTE").eq(1).val(), "")){
        return flag = true ; 
    }
    
    // 자녀선택
    if(nvl($("select[name=sFAMTY] option:selected").eq(0).attr('objps'), "") != nvl($("select[name=sFAMTY] option:selected").eq(1).attr('objps'), "")){
        return flag = true ; 
    }
    
    return flag;
}

function saveChk_Comm(saveType){
    var flag = true;	
	var oBEGDA_after = nvl($("#oBEGDA_after").val(),"");            
    var oENDDA_after = nvl($("#oENDDA_after").val(),"");
    var sFLWTY_after = nvl($("#sFLWTY_after option:selected").val(),"");
    var sTMDTY_after = nvl($("#sTMDTY_after option:selected").val(),"");
    
    var bDate = new Date($("#oBEGDA_after").val().replace(/\./gi, "-"));
    var eDate = new Date($("#oENDDA_after").val().replace(/\./gi, "-"));

    console.log("saveChk_Comm=>", oBEGDA_after, oENDDA_after, sFLWTY_after, sTMDTY_after, bDate, eDate)         
    if(saveType == "REQUEST" || saveType == "REQUPDATE"){
	    if(sFLWTY_after == ""){ //근무유형 확인
	        alert("근무유형을 확인해주세요");
	        return flag;
	    }
	    
	    if(sFLWTY_after != "20" && sFLWTY_after != "80" ){ //세부유형 확인
	        if(sTMDTY_after == ""){
	            alert("세부유형을 확인해주세요");
	            return flag;
	        }
	    }
    }else if(saveType == "REQEND"){
    	var oENDDA_before = nvl($("#oENDDA_before").val().replace(/\./gi, ""), "");
    	if(Number(oENDDA_before) <= Number(oENDDA_after.replace(/\./gi, ""))){
    		alert("종료신청 종료일은 기존 종료일보다 이전이어야 합니다.");
    	    return flag;
    	}
    }
    if(oBEGDA_after == "" || oENDDA_after == ""){ //근무제기간 확인
        alert("유연근무제 기간을 확인해주세요");
        return flag;
    }
    if(bDate > eDate){
        $("#oENDDA_after").focus();
        alert("종료일이 시작일보다 이전입니다");
        return flag;
    }
    
    if($("#iCANFLG_after:checked").val() != 'X'){ //취소 미체크시
	    if(isEssential_file(sFLWTY_after, sTMDTY_after)){ //첨부파일 필수여부 확인
	        var chkFile = 0;
	        if ($("#fileList").find("input[type='file']").length > 0) {
	            $("#fileList").find("input[type='file']").each(function(idx) {
	                if ($(this).val() != "") {
	                    chkFile++;
	                }
	            });
	        }
	        if(chkFile == 0){
	            alert("첨부파일이 1개 이상 추가되어야 합니다.");
	            return flag;
	        }
	    }
    }
    
    if($("#ITAB3_LINE tr").length == 0){ 
        cfAlertMsg("결재선을 지정해 주세요.");
        return flag;
    }
    
    flag = false;
    return flag;
}

function isENDDADiff(){
	var flag = false;
	var oENDDA_before = $("#oENDDA_before").val();
	var oENDDA_after = $("#oENDDA_after").val();
	
	if(oENDDA_before == oENDDA_after){
		flag = true;
	}
	return flag;
}

function isEssential_file(flwty, tmdty){
	var flag = false;
	
	// 첨부파일 필수인지 체크(근무/세부 유형별)
	if(flwty == "10" && tmdty == "20"){
		flag = true;
	}else if(flwty == "20"){
		flag = true;
	}else if(flwty == "30" && tmdty == "20"){
		flag = true;
	}else if(flwty == "60"){
        flag = true;
    }else if(flwty == "80"){
		flag = true;
	}
	return flag;
}

function isIncorrectSelect(){
	var flag = false;
	$("#formDetailDiv_after .dailyTr").each(function(idx){
	    var date = nvl($(this).find("th").text(),"") 
	    var sZAT = nvl($(this).find(".sZAT option:selected").val(),"") 
	    var sBEZ_C = nvl($(this).find("select[name='sBEZ_C'] option:selected").val(),"") 
	    var sBEZ_M = nvl($(this).find("select[name='sBEZ_M'] option:selected").val(),"") 
	    var sENZ_C = nvl($(this).find("select[name='sENZ_C'] option:selected").val(),"") 
	    var sENZ_M = nvl($(this).find("select[name='sENZ_M'] option:selected").val(),"") 
        var sBEZ_C1 = nvl($(this).find("select[name='sBEZ_C_1'] option:selected").val(),""); 
	    var sBEZ_M1 = nvl($(this).find("select[name='sBEZ_M_1'] option:selected").val(),""); 
	    var sENZ_C1 = nvl($(this).find("select[name='sENZ_C_1'] option:selected").val(),""); 
	    var sENZ_M1 = nvl($(this).find("select[name='sENZ_M_1'] option:selected").val(),""); 
	    
//         console.log("test=> ", sZAT, sBEZ_C, sBEZ_M, sENZ_C, sENZ_M)	    	
//         console.log("test1=> ", sZAT, sBEZ_C1, sBEZ_M1, sENZ_C1, sENZ_M1)	
        
	    if(sZAT == ""){
	    	$(this).find(".sZAT").focus();
	        alert(date+"요일 근무구분을 선택해주세요")
	        flag = true;
	        return false;
	    }else if(sZAT == "3" || sZAT == "4"){//휴무일:3, 통상근무:4
	        // 근무구분이 휴무일또는 통상근무인 경우 시작/종료시간은 미선택 또는 '00'으로 선택
	        if(!(sBEZ_C=="" || sBEZ_C=="00") || !(sBEZ_M=="" || sBEZ_M=="00") || !(sENZ_C=="" || sENZ_C=="00") || !(sENZ_M=="" || sENZ_M=="00")){
	            alert(date+"요일 시작 및 종료시간이 잘못 선택되었습니다");
	            flag = true;
	            return false;
	        }else if(!(sBEZ_C1=="" || sBEZ_C1=="00") || !(sBEZ_M1=="" || sBEZ_M1=="00") || !(sENZ_C1=="" || sENZ_C1=="00") || !(sENZ_M1=="" || sENZ_M1=="00")){
	            alert(date+"요일 시작 및 종료시간이 잘못 선택되었습니다");
	            flag = true;
	            return false;
	        }
	    }else if(sZAT == "5"){ //육아시간(근무유형이 80일때)이면 전체 선택 또는 전체 미선택
	    	if(getBlankTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M) != "" && getBlankTime(sBEZ_C1, sBEZ_M1, sENZ_C1, sENZ_M1) != ""){ //전체다 미선택인 경우
	    		alert(date+"요일 시작 및 종료시간을 선택해주세요");
                flag = true;
                return false;
            }else{
		    	if(sBEZ_C=="" && sBEZ_M=="" && sENZ_C=="" && sENZ_M==""){
		            flag = false;
		        }else if(sBEZ_C!="" && sBEZ_M!="" && sENZ_C!="" && sENZ_M!=""){
                    if(isEnddaBigger(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M)){ //시간 체크  - 종료시간이 시작시간보다 큰경우 TRUE, 아니면 false 
                    	alert(date+"요일 시작시간이 종료시간 보다 큽니다.");
                        flag = true;
                        return false;
                    }
		        }else { // 전체 선택/미선택을 제외한 모든 경우에 잘못된 경우로 간주.
	                alert(date+"요일 시작 및 종료시간을 선택해주세요");
	                flag = true;
	                return false;
	            }
		        
		        if(sBEZ_C1=="" && sBEZ_M1=="" && sENZ_C1=="" && sENZ_M1==""){
	                flag = false;
	            }else if(sBEZ_C1!="" && sBEZ_M1!="" && sENZ_C1!="" && sENZ_M1!=""){
                    if(isEnddaBigger(sBEZ_C1, sBEZ_M1, sENZ_C1, sENZ_M1)){ //시간 체크  - 종료시간이 시작시간보다 큰경우 TRUE, 아니면 false 
                    	alert(date+"요일 시작시간이 종료시간 보다 큽니다.");
                        flag = true;
                        return false;
                    }
	            }else { // 전체 선택/미선택을 제외한 모든 경우에 잘못된 경우로 간주.
		            alert(date+"요일 시작 및 종료시간을 선택해주세요");
		            flag = true;
		            return false;
		        }
            }
	    }else {
	    	if(getBlankTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M) != ""){
	    		var target = getBlankTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M);
	        	$(this).find(target).focus();
	            alert(date+"요일 시작 및 종료시간을 선택해주세요");
	    	    flag = true;
                return false;
	    	}else {
                if(isEnddaBigger(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M)){ //시간 체크  - 종료시간이 시작시간보다 큰경우 TRUE, 아니면 false 
                	alert(date+"요일 시작시간이 종료시간 보다 큽니다");
                    flag = true;
                    return false;
                }
	    	}
	    }
	})
	
	return flag;
}

//시간 체크  - 종료시간이 시작시간보다 큰경우 TRUE, 아니면 false 
function isEnddaBigger(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M){
     var flag = false;
	
	 var sBEZ = "".concat(sBEZ_C, sBEZ_M) ; 
     var sENZ = "".concat(sENZ_C, sENZ_M) ; 
     if(Number(sBEZ) > Number(sENZ)){
         flag = true;
     }
     return flag;
}

function getBlankTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M){
    var temp = ""
	if(sBEZ_C == ""){
	    temp = ".sBEZ_C";
    }else if(sBEZ_M == ""){
	    temp = ".sBEZ_M";
    }else if(sENZ_C == ""){
	    temp = ".sENZ_C";
    }else if(sENZ_M == ""){
	    temp = ".sENZ_M";
    }
    return temp;
}

function setSaveForm(saveType){
	document.saveForm.iACTION.value = saveType; //구분
	document.saveForm.iBEGDA.value = nvl($("input[name='oBEGDA_after']").val().replace(/\./gi, ""), ""); //기간 -시작
	document.saveForm.iENDDA.value = nvl($("input[name='oENDDA_after']").val().replace(/\./gi, ""), ""); //기간 -종료
	document.saveForm.iCANFLG.value = (saveType == "REQUPDATE" && nvl($("#iCANFLG_after:checked").val()) == 'X') ? $("#iCANFLG_after:checked").val():""; //취소여부
	document.saveForm.iAPNOTE.value = nvl($("#formDetailDiv_after").find(".oAPNOTE").val(), ""); //신청사유

	if(saveType == "REQEND"){
        document.saveForm.iWKWDAY.value = nvl($("#formCommDiv_after").find(".vWKWDAY").val(), ""); //주간근무일수(근무유형 :40,50)
        document.saveForm.iBEZHOR.value = nvl($("#formCommDiv_after").find(".vBEZHOR").val(), ""); //시작시(근무유형 :40,50)
        document.saveForm.iBEZMIN.value = nvl($("#formCommDiv_after").find(".vBEZMIN").val(), ""); //시작분(근무유형 :40,50)
        document.saveForm.iENZHOR.value = nvl($("#formCommDiv_after").find(".vENZHOR").val(), ""); //종료시(근무유형 :40,50)
        document.saveForm.iENZMIN.value = nvl($("#formCommDiv_after").find(".vENZMIN").val(), ""); //종료분(근무유형 :40,50)		
		document.saveForm.iFLWTY.value = nvl($("#formCommDiv_after").find(".vFLWTY").val(), ""); //근무유형
		document.saveForm.iTMDTY.value = nvl($("#formCommDiv_after").find(".vTMDTY").val(), ""); //세부유형
		document.saveForm.iWKWDY.value = nvl($("#formCommDiv_after").find(".vWKWDY").val(), ""); //주간근무일수
		document.saveForm.iWOSTD.value = nvl($("#formCommDiv_after").find(".vWOSTD").val(), ""); //주간근무시간 (주간육아시간)
		document.saveForm.iFAMTY.value = nvl($("#formCommDiv_after").find(".vFAMTY").val(), ""); //자녀선택
		document.saveForm.iFAMID.value = nvl($("#formCommDiv_after").find(".vFAMID").val(), ""); //자녀선택
		
		if(document.saveForm.iFLWTY.value == "80"){
			document.saveForm.iWEEKNUM.value = nvl($("#formDetailDiv_after").find(".oWEEKNUM").val(), ""); //신청주수
			document.saveForm.iWEEKSUM.value = nvl($("#formDetailDiv_after").find(".oWEEKSUM").val(), ""); //기누적사용
		}
		
		for(var i=0; i<5; i++){
			var zat = $("#formCommDiv_after").find(".vZAT0"+(i+1)).val();
			var bez_c = $("#formCommDiv_after").find(".vBEZ0"+(i+1)+"C").val();
			var bez_m = $("#formCommDiv_after").find(".vBEZ0"+(i+1)+"M").val();
			var enz_c = $("#formCommDiv_after").find(".vENZ0"+(i+1)+"C").val();
			var enz_m = $("#formCommDiv_after").find(".vENZ0"+(i+1)+"M").val();
			var bez_c1 = $("#formCommDiv_after").find(".vBEZ0"+(i+1)+"C_1").val();
			var bez_m1 = $("#formCommDiv_after").find(".vBEZ0"+(i+1)+"M_1").val();
			var enz_c1 = $("#formCommDiv_after").find(".vENZ0"+(i+1)+"C_1").val();
			var enz_m1 = $("#formCommDiv_after").find(".vENZ0"+(i+1)+"M_1").val();
			var ars = $("#formCommDiv_after").find(".vARS0"+(i+1)).val();
			var ars1 = $("#formCommDiv_after").find(".vARS0"+(i+1)+"_1").val();
			var sui = $("#formCommDiv_after").find(".vSUI0"+(i+1)).val();
			
			$("#saveForm").find("input[name=iZAT0"+(i+1)+"]").val(nvl(zat,""));
			$("#saveForm").find("input[name=iBEZ0"+(i+1)+"C]").val(nvl(bez_c,""));
			$("#saveForm").find("input[name=iBEZ0"+(i+1)+"M]").val(nvl(bez_m,""));
			$("#saveForm").find("input[name=iENZ0"+(i+1)+"C]").val(nvl(enz_c,""));
			$("#saveForm").find("input[name=iENZ0"+(i+1)+"M]").val(nvl(enz_m,""));
			$("#saveForm").find("input[name=iBEZ0"+(i+1)+"C_1]").val(nvl(bez_c1,""));
			$("#saveForm").find("input[name=iBEZ0"+(i+1)+"M_1]").val(nvl(bez_m1,""));
			$("#saveForm").find("input[name=iENZ0"+(i+1)+"C_1]").val(nvl(enz_c1,""));
			$("#saveForm").find("input[name=iENZ0"+(i+1)+"M_1]").val(nvl(enz_m1,""));
			$("#saveForm").find("input[name=iARS0"+(i+1)+"]").val(nvl(ars,""));
			$("#saveForm").find("input[name=iARS0"+(i+1)+"_1]").val(nvl(ars1,""));
			$("#saveForm").find("input[name=iSUI0"+(i+1)+"]").val(nvl(sui,""));
			
		}
	}else{
	    document.saveForm.iWKWDAY.value = nvl($("#formDetailDiv_after").find(".sWKWDAY option:selected").val(), ""); //주간근무일수(근무유형 :40,50)
	    document.saveForm.iBEZHOR.value = nvl($("#formDetailDiv_after").find(".sBEZHOR option:selected").val(), ""); //시작시(근무유형 :40,50)
	    document.saveForm.iBEZMIN.value = nvl($("#formDetailDiv_after").find(".sBEZMIN option:selected").val(), ""); //시작분(근무유형 :40,50)
	    document.saveForm.iENZHOR.value = nvl($("#formDetailDiv_after").find(".sENZHOR option:selected").val(), ""); //종료시(근무유형 :40,50)
	    document.saveForm.iENZMIN.value = nvl($("#formDetailDiv_after").find(".sENZMIN option:selected").val(), ""); //종료분(근무유형 :40,50)
	    document.saveForm.iARSTIM.value = nvl($("#formDetailDiv_after").find(".sARSTIM").val(), ""); //근무시간(근무유형 :40,50)
		document.saveForm.iFLWTY.value = nvl($("#sFLWTY_after option:selected").val(), ""); //근무유형
		document.saveForm.iTMDTY.value = nvl($("#sTMDTY_after option:selected").val(), ""); //세부유형
		document.saveForm.iWKWDY.value = nvl($("#formCommDiv_after .workDayWeek").find("input[type=text]").val(), ""); //주간근무일수
		document.saveForm.iWOSTD.value = nvl($("#formCommDiv_after .workTimeWeek").find("input[type=text]").val(), ""); //주간근무시간 (주간육아시간)
		
        document.saveForm.iFAMTY.value = nvl($("#formDetailDiv_after").find(".sFAMTY option:selected").val(), ""); //자녀선택
        document.saveForm.iFAMID.value = nvl($("#formDetailDiv_after").find(".sFAMTY option:selected").attr("objps"), ""); //자녀선택
        document.saveForm.iWEEKNUM.value = nvl($("#formDetailDiv_after").find(".oWEEKNUM").val(), ""); //신청주수
        document.saveForm.iWEEKSUM.value = nvl($("#formDetailDiv_after").find(".oWEEKSUM").val(), ""); //기누적사용		
		$("#formDetailDiv_after .dailyTr").each(function(i){
			var sZAT = $(this).find("select[name=sZAT] option:selected").val();
			var sBEZ_C = $(this).find("select[name=sBEZ_C] option:selected").val();
			var sBEZ_M = $(this).find("select[name=sBEZ_M] option:selected").val();
			var sENZ_C = $(this).find("select[name=sENZ_C] option:selected").val();
			var sENZ_M = $(this).find("select[name=sENZ_M] option:selected").val();
			var sBEZ_C1 = $(this).find("select[name=sBEZ_C_1] option:selected").val();
			var sBEZ_M1 = $(this).find("select[name=sBEZ_M_1] option:selected").val();
			var sENZ_C1 = $(this).find("select[name=sENZ_C_1] option:selected").val();
			var sENZ_M1 = $(this).find("select[name=sENZ_M_1] option:selected").val();
			var oARS = $(this).find(".oARS").val();
			var oARS1 = $(this).find(".oARS_1").val();
			var oSUI = $(this).find(".oSUI:checked").val();

			$("#saveForm").find("input[name=iZAT0"+(i+1)+"]").val(nvl(sZAT,""));
            $("#saveForm").find("input[name=iBEZ0"+(i+1)+"C]").val(nvl(sBEZ_C,""));
            $("#saveForm").find("input[name=iBEZ0"+(i+1)+"M]").val(nvl(sBEZ_M,""));
            $("#saveForm").find("input[name=iENZ0"+(i+1)+"C]").val(nvl(sENZ_C,""));
            $("#saveForm").find("input[name=iENZ0"+(i+1)+"M]").val(nvl(sENZ_M,""));
            $("#saveForm").find("input[name=iBEZ0"+(i+1)+"C_1]").val(nvl(sBEZ_C1,""));
            $("#saveForm").find("input[name=iBEZ0"+(i+1)+"M_1]").val(nvl(sBEZ_M1,""));
            $("#saveForm").find("input[name=iENZ0"+(i+1)+"C_1]").val(nvl(sENZ_C1,""));
            $("#saveForm").find("input[name=iENZ0"+(i+1)+"M_1]").val(nvl(sENZ_M1,""));
            $("#saveForm").find("input[name=iARS0"+(i+1)+"]").val(nvl(oARS,""));
            $("#saveForm").find("input[name=iARS0"+(i+1)+"_1]").val(nvl(oARS1,""));
            $("#saveForm").find("input[name=iSUI0"+(i+1)+"]").val(nvl(oSUI,""));
		})
	}
	
}

//취소체크 
$("#iCANFLG_after").off().on("click", function(){
    var flwty_before = $("#sFLWTY_before option:selected").val();
    var tmdty_before = $("#sTMDTY_before option:selected").val();
    var oBEGDA_before = $("#oBEGDA_before").val();
    var oENDDA_before = $("#oENDDA_before").val();
	    
    $("#oBEGDA_after").val(oBEGDA_before);
    $("#oENDDA_after").val(oENDDA_before);
    
  	param.changeFlag = "after";
  	
  	// 취소여부 체크 
    if($(this).prop('checked') ){
	    param.cancelYn ="Y";
        $("#formCommDiv_after").find("#sFLWTY_after").prop("disabled", true);
        $("#formCommDiv_after").find("#sTMDTY_after").prop("disabled", true);
        $("#formCommDiv_after").find('input[name*=DA_after]').prop("disabled", true);
        $("#formCommDiv_after").find('label[for*=DA_after]').hide();
    }else {
    	param.cancelYn =""; //초기화
        $("#formCommDiv_after").find("#sFLWTY_after").prop("disabled", false);
        $("#formCommDiv_after").find("#sTMDTY_after").prop("disabled", false);
        $("#formCommDiv_after").find('input[name*=DA_after]').prop("disabled", false);
        $("#formCommDiv_after").find('label[for*=DA_after]').show();
    }
    
  	// 유형 선택 변경
    if(flwty_before == "20" || flwty_before == "80"){
        $("#sFLWTY_after").val(flwty_before).trigger("change");
    }else {
        $("#sFLWTY_after").val(flwty_before).trigger("change");
        $("#sTMDTY_after").val(tmdty_before).trigger("change");
    }
})

//근무시간 계산
function calcWorkTime(stH, stM, edH, edM, sFLWTY, suiChk){
    var result = "";
    console.log(stH, stM, edH, edM, sFLWTY, suiChk )
    if(stH =="" || stM == "" || edH == "" || edM == ""){
        return result;
    }
    stM = stM =="30" ? "50": stM;
    edM = edM =="30" ? "50": edM;  
    var calcVal = Number(edH+""+edM) - Number(stH+""+stM);
    var rest = getRestTime(stH, stM, edH, edM, sFLWTY, suiChk)* 100 ; 
    console.log("calcTest=>", calcVal, rest)
    
    calcVal = calcVal-rest; //근무시간 - 식사시간
    
    if(calcVal>=0){ //0 이상일때
    	calcVal = fillZero(4, String(calcVal));
	    result = calcVal.substring(0,2) + "." + calcVal.substring(2,4);
    }else{ //음수일때
    	calcVal *= -1
	    calcVal = fillZero(4, String(calcVal));
	    result = "-"+ calcVal.substring(0,2) + "." + calcVal.substring(2,4);
    }
    return Number(result).toFixed(2);
}


// 휴게시간(점심시간) 구하기
function getRestTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M, sFLWTY, suiChk){
	var rest = 0;
	console.log("getRestTime=>", sBEZ_C, sBEZ_M, sENZ_C, sENZ_M, sFLWTY)
	if(nvl(sBEZ_C,"") == "" || nvl(sBEZ_M,"") == "" || nvl(sENZ_C,"") == "" || nvl(sENZ_M,"") == "" ){
		return rest;
	}
	
	sBEZ_M = (sBEZ_M == '30') ? '50' : sBEZ_M;
	sENZ_M = (sENZ_M == '30') ? '50' : sENZ_M;
	var sBEZ = Number("".concat(sBEZ_C, sBEZ_M));
	var sENZ = Number("".concat(sENZ_C, sENZ_M));
	
	if(sFLWTY == "40" || sFLWTY == "50"){
	    if((sENZ - sBEZ) > 400){ // 일 근무시간이 4시간 초과 시, 휴게시간 60분 부여
	    	rest = 1;
	    }
	}else if(sFLWTY == "80"){
		if(sBEZ <= 1200 && 1300 <= sENZ){ // 점심시간(12~13시)가 포함되는 경우만 식사시간 1시간으로 인정(12시30분 시작 또는 종료인 경우 근무시간으로 허용) 
            rest = 1;
        } else if(sBEZ == 1250 || 1250 == sENZ){
            rest = 0.5;
        }
	}else{
		if(sBEZ <= 1200 && 1300 <= sENZ){ // 점심시간(12~13시)가 포함되는 경우만 식사시간 1시간으로 인정(12시30분 시작 또는 종료인 경우 근무시간으로 허용) 
		    rest = 1;
		}
	}
   	
	if(sFLWTY == "20" && suiChk == true ){ // 저녁시간(18~19시)가 포함되는 경우만 식사시간 1시간으로 인정(18시30분 시작 또는 종료인 경우 근무시간으로 허용) 
	    if(sBEZ <= 1800 && 1900 <= sENZ ){
	        rest += 1;
	    }
    }

	return rest;
}


// 근무유형 40,50에서 사용
function getTimeHm(zlcty){
    var obj = {
            'sBEZ_C':'',
            'sBEZ_M':'',
            'sENZ_C':'',
            'sENZ_M':'',
            'sBEZ':'',
            'sENZ':'',
            'sWKWDAY':''
    }; //시작 시간, 분, 종료 시간, 분
    
    var timeSettingTable = $("#formDetailDiv_after").find("#timeSettingTable");
    obj.sBEZ_C = nvl($(timeSettingTable).find(".sBEZ_C option:selected").val(), "");
    obj.sBEZ_M = nvl($(timeSettingTable).find(".sBEZ_M option:selected").val(), "");
    obj.sWKWDAY =  nvl($(timeSettingTable).find(".sWKWDAY option:selected").val(), "");

    if(obj.sWKWDAY=="" || obj.sBEZ_C =="" || obj.sBEZ_C==""){
        return obj;
    }
    
    obj.sBEZ = "".concat(obj.sBEZ_C, ".", (obj.sBEZ_M == "30" ? "50" : obj.sBEZ_M))    
    
    var wostd = $("#sTMDTY_after option:selected").attr("wostd").trim(); //주간근무시간
    var max = Number(wostd)/Number(obj.sWKWDAY);
    
    obj.sENZ = Number(obj.sBEZ) + Number(max);
    obj.sENZ_C = String(obj.sENZ).split('.')[0];
    obj.sENZ_C = obj.sENZ_C > 10 ? obj.sENZ_C : fillZero(2, obj.sENZ_C);
    obj.sENZ_M = String(obj.sENZ).split('.')[1] == '5' ? '30': '00';
    
    var restTime = getRestTime(obj.sBEZ_C, obj.sBEZ_M, obj.sENZ_C, obj.sENZ_M, zlcty); 
    obj.sENZ = Number(obj.sBEZ) + Number(max) + restTime;
    obj.sENZ_C = String(obj.sENZ).split('.')[0];
    obj.sENZ_C = obj.sENZ_C > 10 ? obj.sENZ_C : fillZero(2, obj.sENZ_C);
    obj.sENZ_M = String(obj.sENZ).split('.')[1] == '5' ? '30': '00';
    
    return obj;
}

</script>
<div class="content" id ="content_form">
    <form name="saveForm" id="saveForm" method="post">
        <input type="hidden" name="iACTION" value=""/> <!-- ajax템플릿(SEARCH:검색, DETAIL:상세조회, .... )  -->              
        <input type="hidden" name="iFLWNO" id="iFLWNO" value="${reqParam.I_FLWNO}"/> <!-- 신청번호 -->                         
        <input type="hidden" name="iSEQNR" id="iSEQNR" value="${reqParam.I_SEQNR}"/> <!-- 신청번호(seq)-->                         
        <input type="hidden" name="iBEGDA" value=""/>               <!-- 시작일 -->
        <input type="hidden" name="iENDDA" value=""/>               <!-- 종료일 -->           
        <input type="hidden" name="iFLWTY" value=""/>               <!-- 근무유형 -->           
        <input type="hidden" name="iTMDTY" value=""/>               <!-- 세부유형-->           
        <input type="hidden" name="iCANFLG" value=""/>               <!-- 취소여부-->           
        <input type="hidden" name="iWKWDAY" value=""/>               <!-- 주간근무일수(근무유형:40,50 일떄 선택)-->           
        <input type="hidden" name="iBEZHOR" value=""/>               <!-- 시작시(근무유형:40,50 일떄 선택)-->           
        <input type="hidden" name="iBEZMIN" value=""/>               <!-- 시작분(근무유형:40,50 일떄 선택)-->           
        <input type="hidden" name="iENZHOR" value=""/>               <!-- 종쵸시(근무유형:40,50 일떄 선택)-->           
        <input type="hidden" name="iENZMIN" value=""/>               <!-- 종료분(근무유형:40,50 일떄 선택)-->           
        <input type="hidden" name="iARSTIM" value=""/>               <!-- 근무시간(근무유형:40,50 일떄 선택)-->           
        <input type="hidden" name="ZDSFLAG" id="ZDSFLAG" value="3" /><!-- 첨부파일 문서구분 -->
        <input type="hidden" name="iFAMTY" value="" /><!-- 자녀선택 -->
        <input type="hidden" name="iFAMID" value="" /><!-- 자녀선택 -->
        <input type="hidden" name="iWEEKNUM" value="" /><!-- 신청주수 -->
        <input type="hidden" name="iWEEKSUM" value="" /><!-- 기누적사용 -->
        
        <input type="hidden" name="ENDDAFLG" id="ENDDAFLG" value="${reqParam.ACTION eq 'ENDAPPLY' ? 'X':''}" /><!-- 종료신청시 'X' -->
        
        <input type="hidden" name="iZAT01" id="iZAT01" value=""/>              <!-- 근무구분-월 -->   
        <input type="hidden" name="iZAT02" id="iZAT02" value=""/>              <!-- 근무구분-화 -->   
        <input type="hidden" name="iZAT03" id="iZAT03" value=""/>              <!-- 근무구분-수 -->   
        <input type="hidden" name="iZAT04" id="iZAT04" value=""/>              <!-- 근무구분-목 --> 
        <input type="hidden" name="iZAT05" id="iZAT05" value=""/>              <!-- 근무구분-금 --> 
        <input type="hidden" name="iBEZ01C" id="iBEZ01C" value=""/>              <!-- 시작시간 시-월 -->   
        <input type="hidden" name="iBEZ02C" id="iBEZ02C" value=""/>              <!-- 시작시간 시-화 -->                
        <input type="hidden" name="iBEZ03C" id="iBEZ03C" value=""/>              <!-- 시작시간 시-수 -->                
        <input type="hidden" name="iBEZ04C" id="iBEZ04C" value=""/>              <!-- 시작시간 시-목 -->                
        <input type="hidden" name="iBEZ05C" id="iBEZ05C" value=""/>              <!-- 시작시간 시-금 -->                
        <input type="hidden" name="iBEZ01M" id="iBEZ01M" value=""/>              <!-- 시작시간 분-월 -->   
        <input type="hidden" name="iBEZ02M" id="iBEZ02M" value=""/>              <!-- 시작시간 분-화 -->                
        <input type="hidden" name="iBEZ03M" id="iBEZ03M" value=""/>              <!-- 시작시간 분-수 -->                
        <input type="hidden" name="iBEZ04M" id="iBEZ04M" value=""/>              <!-- 시작시간 분-목 -->                
        <input type="hidden" name="iBEZ05M" id="iBEZ05M" value=""/>              <!-- 시작시간 분-금 -->                
        <input type="hidden" name="iENZ01C" id="iENZ01C" value=""/>             <!-- 종료시간 시-월 -->   
        <input type="hidden" name="iENZ02C" id="iENZ02C" value=""/>              <!-- 종료시간 시-화 -->                
        <input type="hidden" name="iENZ03C" id="iENZ03C" value=""/>              <!-- 종료시간 시-수 -->                
        <input type="hidden" name="iENZ04C" id="iENZ04C" value=""/>              <!-- 종료시간 시-목 -->                
        <input type="hidden" name="iENZ05C" id="iENZ05C" value=""/>              <!-- 종료시간 시-금 -->                
        <input type="hidden" name="iENZ01M" id="iENZ01M" value=""/>              <!-- 종료시간 분-월 -->   
        <input type="hidden" name="iENZ02M" id="iENZ02M" value=""/>              <!-- 종료시간 분-화 -->                
        <input type="hidden" name="iENZ03M" id="iENZ03M" value=""/>              <!-- 종료시간 분-수 -->                
        <input type="hidden" name="iENZ04M" id="iENZ04M" value=""/>              <!-- 종료시간 분-목 -->                
        <input type="hidden" name="iENZ05M" id="iENZ05M" value=""/>              <!-- 종료시간 분-금 -->     
        <input type="hidden" name="iARS01" id="iARS01" value=""/>              <!-- 일근무시간-월-->     
        <input type="hidden" name="iARS02" id="iARS02" value=""/>              <!-- 일근무시간-화-->     
        <input type="hidden" name="iARS03" id="iARS03" value=""/>              <!-- 일근무시간-수-->     
        <input type="hidden" name="iARS04" id="iARS04" value=""/>              <!-- 일근무시간-목-->     
        <input type="hidden" name="iARS05" id="iARS05" value=""/>              <!-- 일근무시간-금-->   
        <input type="hidden" name="iSUI01" id="iSUI01" value=""/>              <!-- 석식포함-월-->   
        <input type="hidden" name="iSUI02" id="iSUI02" value=""/>              <!-- 석식포함-화-->   
        <input type="hidden" name="iSUI03" id="iSUI03" value=""/>              <!-- 석식포함-수-->   
        <input type="hidden" name="iSUI04" id="iSUI04" value=""/>              <!-- 석식포함-목-->   
        <input type="hidden" name="iSUI05" id="iSUI05" value=""/>              <!-- 석식포함-금-->   
        
          
        <input type="hidden" name="iAPNOTE" id="iAPNOTE" value=""/>              <!-- 신청사유-->     
        <input type="hidden" name="iWOSTD" id="iiWOSTD" value=""/>              <!-- 주간근무시간-->     
        <input type="hidden" name="iWKWDY" id="iWKWDY" value=""/>              <!-- 주간근무일수-->     
 
        <input type="hidden" name="iBEZ01C_1" id="iBEZ01C_1" value=""/>              <!-- 시작시간 시-월 -->   
        <input type="hidden" name="iBEZ02C_1" id="iBEZ02C_1" value=""/>              <!-- 시작시간 시-화 -->                
        <input type="hidden" name="iBEZ03C_1" id="iBEZ03C_1" value=""/>              <!-- 시작시간 시-수 -->                
        <input type="hidden" name="iBEZ04C_1" id="iBEZ04C_1" value=""/>              <!-- 시작시간 시-목 -->                
        <input type="hidden" name="iBEZ05C_1" id="iBEZ05C_1" value=""/>              <!-- 시작시간 시-금 -->                
        <input type="hidden" name="iBEZ01M_1" id="iBEZ01M_1" value=""/>              <!-- 시작시간 분-월 -->   
        <input type="hidden" name="iBEZ02M_1" id="iBEZ02M_1" value=""/>              <!-- 시작시간 분-화 -->                
        <input type="hidden" name="iBEZ03M_1" id="iBEZ03M_1" value=""/>              <!-- 시작시간 분-수 -->                
        <input type="hidden" name="iBEZ04M_1" id="iBEZ04M_1" value=""/>              <!-- 시작시간 분-목 -->                
        <input type="hidden" name="iBEZ05M_1" id="iBEZ05M_1" value=""/>              <!-- 시작시간 분-금 -->                
        <input type="hidden" name="iENZ01C_1" id="iENZ01C_1" value=""/>             <!-- 종료시간 시-월 -->   
        <input type="hidden" name="iENZ02C_1" id="iENZ02C_1" value=""/>              <!-- 종료시간 시-화 -->                
        <input type="hidden" name="iENZ03C_1" id="iENZ03C_1" value=""/>              <!-- 종료시간 시-수 -->                
        <input type="hidden" name="iENZ04C_1" id="iENZ04C_1" value=""/>              <!-- 종료시간 시-목 -->                
        <input type="hidden" name="iENZ05C_1" id="iENZ05C_1" value=""/>              <!-- 종료시간 시-금 -->                
        <input type="hidden" name="iENZ01M_1" id="iENZ01M_1" value=""/>              <!-- 종료시간 분-월 -->   
        <input type="hidden" name="iENZ02M_1" id="iENZ02M_1" value=""/>              <!-- 종료시간 분-화 -->                
        <input type="hidden" name="iENZ03M_1" id="iENZ03M_1" value=""/>              <!-- 종료시간 분-수 -->                
        <input type="hidden" name="iENZ04M_1" id="iENZ04M_1" value=""/>              <!-- 종료시간 분-목 -->                
        <input type="hidden" name="iENZ05M_1" id="iENZ05M_1" value=""/>              <!-- 종료시간 분-금 -->   
        <input type="hidden" name="iARS01_1" id="iARS01_1" value=""/>              <!-- 일근무시간-월-->     
        <input type="hidden" name="iARS02_1" id="iARS02_1" value=""/>              <!-- 일근무시간-월-->     
        <input type="hidden" name="iARS03_1" id="iARS03_1" value=""/>              <!-- 일근무시간-월-->     
        <input type="hidden" name="iARS04_1" id="iARS04_1" value=""/>              <!-- 일근무시간-월-->     
        <input type="hidden" name="iARS05_1" id="iARS05_1" value=""/>              <!-- 일근무시간-월-->         
	    <c:set var="titleText" value =""/>
	    <c:choose>
	        <c:when test="${reqParam.ACTION eq 'DETAIL' }"><c:set var="titleText" value ="상세정보"/></c:when>
	        <c:when test="${reqParam.ACTION eq 'APPLY' }"><c:set var="titleText" value ="신규신청"/></c:when>
	        <c:when test="${reqParam.ACTION eq 'UPDATE' }"><c:set var="titleText" value ="결재변경"/></c:when>
	        <c:when test="${reqParam.ACTION eq 'ENDAPPLY' }"><c:set var="titleText" value ="종료신청"/></c:when>
		</c:choose>
		<c:if test="${titleText ne ''}">
		    <div class="title_top">
		        <p class="tit_02">${titleText}</p>
		    </div>
		</c:if>
		
		<c:if test="${titleUseYn eq 'Y'}">
            <div class="formDiv" id="formDiv_before">
		        <c:import url="/WEB-INF/jsp/ess/pa/FlexibleWork_Comm.jsp">
		            <c:param name="changeFlag">before</c:param>
		            <c:param name="titleUseYn">${titleUseYn}</c:param>
		        </c:import>
            </div>	
	    </c:if>
		<div class="formDiv" id="formDiv_after">
		    <c:import url="/WEB-INF/jsp/ess/pa/FlexibleWork_Comm.jsp">
		        <c:param name="changeFlag">after</c:param>
		        <c:param name="titleUseYn">${titleUseYn}</c:param>
		    </c:import>	
		</div>
		
		<c:if test="${reqParam.ACTION eq 'APPLY' || reqParam.ACTION eq 'UPDATE'}">
			<div class="text-danger">
                <p>※ 유연근무제 활용자는 유연근무 유형에 맞는 근태기록 관리 철저.</p>
			</div>	
		</c:if>
		<!-- 결재선 -->	
        <div class="title_top" style="margin-top:20px;">
            <p class="tit_02">결재선 정보</p>
        </div>
        <table summary="결재선 정보" class="table_st01">
            <caption>결재선 정보</caption>
            <colgroup>
                <col width="160px">
                <col width="*">
                <col width="160px">
                <col width="*">
            </colgroup>
            <tbody>
                <tr>
                    <th>기안자 의견</th>
                    <td colspan="3">
                        <textarea name="LINE" id="LINE" rows="3">${ITAB4[0].LINE}</textarea>
                    </td>
                </tr>
            </tbody>
        </table>
        
        <%-- 첨부파일 include --%>                    
        <jsp:include page="/WEB-INF/jsp/include/ess_attach_file.jsp" >  
            <jsp:param name="T_FILEINFO" value="${T_FILEINFO}" ></jsp:param>
        </jsp:include>
        <%-- 첨부파일 include --%>   
        
        <div class="btn_wrap">
            <div class="btn_right">
               <a href="javascript:void(0);" class="btn btn_1" id="btn_approval">결재선 지정</a>
            </div>
        </div>
            
            
        <div class="title_top">
            <p class="tit_02">결재라인</p>
        </div>  
        
        <%-- 결재자지정 include --%>   
        <jsp:include page="/WEB-INF/jsp/include/ess_approval_line.jsp" >    
            <jsp:param name="ITAB3" value="${ITAB3}" ></jsp:param>
        </jsp:include>
        <%-- 결재자지정 include --%>   
        
        <c:if test="${reqParam.ACTION eq 'APPLY' || reqParam.ACTION  eq 'UPDATE' || reqParam.ACTION  eq 'ENDAPPLY'}">
		    <div class="btn_wrap">
		        <div class="btn_right">
		            <c:set var="saveType" value="" />
		            <c:choose>
		                <c:when test="${reqParam.ACTION  eq 'APPLY'}">
		                    <c:set var="saveType" value="REQUEST" />
		                </c:when>
		                <c:when test="${reqParam.ACTION  eq 'UPDATE'}">
		                    <c:set var="saveType" value="REQUPDATE" />
		                </c:when>
		                <c:when test="${reqParam.ACTION  eq 'ENDAPPLY'}">
		                    <c:set var="saveType" value="REQEND" />
		                </c:when>
		            </c:choose>
		            <a href="javascript:fn_save('${saveType}');" class="btn btn_1" id="btnApv">결재요청</a>
		        </div>
		    </div>
		</c:if>
		
		<c:if test="${reqParam.ACTION eq 'APPLY' || reqParam.ACTION eq 'UPDATE'}">
			<div class="text-danger">
	            <p>※ 소속부서장까지 결재자를 지정하세요.</p>
	            <p>※ 시간선택제는 본사인사담당자(${E_MENAME })를 첫번째 결재자로 지정하세요.</p>
			</div>
		</c:if>
		<input type="hidden" name="importSaveTest" />  <!-- ie에서 마지막 입력추가(안하면 에러남) -->
    </form>    
</div>

<%-- 결재 script include --%>
<jsp:include page="/WEB-INF/jsp/include/ess_approval_script.jsp"/>  
<%-- 결재 script include --%>  