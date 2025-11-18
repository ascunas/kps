<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%-- <%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%> --%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<c:set var="now" value="<%=new java.util.Date()%>"/>
<c:set var="today"><fmt:formatDate value="${now}" pattern="yyyy.MM.dd"/></c:set>


<script>
Date.prototype.getWeek =function(dowOffset) {
    dowOffset = typeof(dowOffset) == 'number' ? dowOffset : 0;
    var newYear = new Date(this.getFullYear(), 0, 1);
    var day = newYear.getDate()- dowOffset;
    day = (day >= 0? day : day+7);
    var daynum = Math.floor((this.getTime()- newYear.getTime() -(this.getTimezoneOffset() - newYear.getTimezoneOffset())*60000)/86400000) + 1;
    var weeknum;
    
    if(day<4){
        weeknum=Math.floor((daynum+day-1)/7) +1;
        if(weeknum>52){
            var nYear = new Date(this.getFullYear() + 1, 0, 1);
            var nday = nYear.getDay() - dowOffset;
            nday =nday >= 0 ? nday : nday +7;
            weeknum = nday < 4 ? 1:53;
        }
    }else {
        weeknum = Math.floor((daynum+day-1)/7);
    }
    return weeknum;
}

$(document).ready(function(){

    param.changeFlag ="${reqParam.changeFlag}";
    param.endApplyYn ="${reqParam.endApplyYn}";
    param.cancelYn ="${reqParam.cancelYn}";
    param.zlcty ="${reqParam.zlcty}";
    param.zlcod ="${reqParam.zlcod}";
    param.msgCode ="${reqParam.msgCode}";
    param.message ="${reqParam.message}";

    console.log("type80 param=>",param)
    
    var formDiv =  "#formDiv_"+param.changeFlag;
    if(param.ACTION == "ENDAPPLY" && param.changeFlag == "after"){
        var begda = $(formDiv).find(".vBEGDA").val();
        $("#oBEGDA_after").val(begda);
        
        $("#oBEGDA_after").prop("disabled",true);
        $("#oBEGDA_after").siblings("label").css("display","none");
        
        appendOptions("sFAMTY", param.changeFlag, getSelectOptions("sFAMTY", param.changeFlag, param.zlcty, param.zlcod));
        markEtc(param);
        
        var dataObj = new Object();
        dataObj.iFAMID = nvl($("#formDetailDiv_after").find(".sFAMTY option:selected").attr("objps"), "");
        dataObj.iFLWNO = document.saveForm.iFLWNO.value;
        dataObj.iBEGDA = nvl($("input[name='oBEGDA_after']").val().replace(/\./gi, ""), "");
        getAccumulastedWeek(dataObj);
        
        return;
    } else if (param.ACTION == "DETAIL" && param.changeFlag == "after" && param.endApplyYn == 'Y'){
        var begda = $(formDiv).find(".vBEGDA").val();
        var endda = $(formDiv).find(".vENDDA").val();
        var vAPNOTE = $("#formCommDiv_after").find(".vAPNOTE").val();
        
        $("#oBEGDA_after").val(begda);
        $("#oENDDA_after").val(endda);
        $("#formDetailDiv_after").find('.oAPNOTE').val(vAPNOTE);
        
        appendOptions("sFAMTY", param.changeFlag, getSelectOptions("sFAMTY", param.changeFlag, param.zlcty, param.zlcod));
        markEtc(param);
        
        $("#formDetailDiv_after").find('label').css("display","none");
        $("#formDetailDiv_after").find('input[type=text]').prop("disabled",true);
        return;
    } 
    
    
    // 옵션 셋팅
    appendOptions("sZAT", param.changeFlag, getSelectOptions("sZAT", param.changeFlag, param.zlcty, param.zlcod));
    appendOptions("sBEZ_C", param.changeFlag, getSelectOptions("sBEZ_C", param.changeFlag, param.zlcty, param.zlcod));
    appendOptions("sBEZ_M", param.changeFlag, getSelectOptions("sBEZ_M", param.changeFlag, param.zlcty, param.zlcod));
    appendOptions("sENZ_C", param.changeFlag, getSelectOptions("sENZ_C", param.changeFlag, param.zlcty, param.zlcod));
    appendOptions("sENZ_M", param.changeFlag, getSelectOptions("sENZ_M", param.changeFlag, param.zlcty, param.zlcod));
    appendOptions("sFAMTY", param.changeFlag, getSelectOptions("sFAMTY", param.changeFlag, param.zlcty, param.zlcod));

    // 결과값 셋팅
    var workDayWeek = 0;    //주간근무일수
    var workTimeWeek = 0;   //주간육아시간
    $(formDiv).find(".dailyTr").each(function(idx){
        
        // select-option selected 셋팅
        markOptionSelected(this, "sZAT", param);
        markOptionSelected(this, "sBEZ_C", param);
        markOptionSelected(this, "sBEZ_M", param);
        markOptionSelected(this, "sENZ_C", param);
        markOptionSelected(this, "sENZ_M", param);
        
        markOptionSelected(this, "sBEZ_C_1", param);
        markOptionSelected(this, "sBEZ_M_1", param);
        markOptionSelected(this, "sENZ_C_1", param);
        markOptionSelected(this, "sENZ_M_1", param);
        
        //근무시간
        var time = getWorkTime(this, param);
        setWorkTime(this, time);
        var time1 = getWorkTime1(this, param);
        setWorkTime1(this, time1);
        
        var sZAT = $(this).find(".sZAT option:selected").val() ;
        workDayWeek += (sZAT != "" && sZAT != "3") ? 1 : 0;   //휴무일이 아니면 근무일
        workTimeWeek += (sZAT == "5") ? Number(time) + Number(time1) : 0; // 근무구분이 육아시간인 경우만 합산
    })
    
    if(param.ACTION == "APPLY" || (param.ACTION == "UPDATE" && param.changeFlag == "after") ){
	    $(formDiv).find(".workDayWeek input[type=text]").val(workDayWeek.toFixed(2))
	    $(formDiv).find(".workTimeWeek input[type=text]").val(workTimeWeek.toFixed(2))
    }
    
    markApNote(param); //신청사유 표시
    
    markEtc(param);
    if(param.ACTION == "DETAIL"){
        fn_detailAttrDisabled_${reqParam.changeFlag}();
    }else if(param.ACTION == "APPLY"){
        fn_detailAttrEnabled_${reqParam.changeFlag}(param);
    }else if(param.ACTION == "UPDATE"){
        if("after" == param.changeFlag){
            if($("#iCANFLG_after").prop("checked")){
                fn_detailAttrDisabled_${reqParam.changeFlag}();
            }else{
                fn_detailAttrEnabled_${reqParam.changeFlag}(param);
            }
        }else if("before" == param.changeFlag){
            fn_detailAttrDisabled_${reqParam.changeFlag}();
        }
    }else if(param.ACTION == "ENDAPPLY"){
    	if("before" == param.changeFlag){
            fn_detailAttrDisabled_${reqParam.changeFlag}();
        }
    }
    
})

function markOptionSelected(dailyTr, type, param){
    if(type == "" || param.ACTION == ""){return;}

    var formCommDiv =  "#formCommDiv_"+param.changeFlag;
    var formDetailDiv =  "#formDetailDiv_"+param.changeFlag;
    var idx = $(dailyTr).index();
    var selectedVal, selectNm = "";
    if(param.ACTION == "APPLY" || (param.ACTION == "UPDATE" && param.initYn == "Y")){

    } else {
        var sZAT = $(dailyTr).find(".sZAT").val();
        
        if(type == 'sZAT'){
            selectNm = ".v"+type.substr(1)+"0"+(idx+1);
            selectedVal = $(formCommDiv).find(selectNm).val().trim();
        } else if (type == 'sBEZ_C' || type == 'sENZ_C'){
            selectNm = ".v"+type.substr(1,3)+"0"+(idx+1)+"C";
            selectedVal = (sZAT == "4") ? "" : $(formCommDiv).find(selectNm).val();
        } else if (type == 'sBEZ_C_1' || type == 'sENZ_C_1'){
            selectNm = ".v"+type.substr(1,3)+"0"+(idx+1)+"C_1";
            selectedVal = (sZAT == "4") ? "" : $(formCommDiv).find(selectNm).val();
        } else if (type == 'sBEZ_M' || type == 'sENZ_M'){
            var hour = nvl($(formCommDiv).find(".v"+type.substr(1,3)+"0"+(idx+1)+"C").val(), "");
            if(hour != "00" && hour != ""){
                selectNm = ".v"+type.substr(1,3)+"0"+(idx+1)+"M";
                selectedVal = (sZAT == "4") ? "" : $(formCommDiv).find(selectNm).val();
            }
        } else if (type == 'sBEZ_M_1' || type == 'sENZ_M_1'){
            var hour = nvl($(formCommDiv).find(".v"+type.substr(1,3)+"0"+(idx+1)+"C_1").val(), "");
            if(hour != "00" && hour != ""){
                selectNm = ".v"+type.substr(1,3)+"0"+(idx+1)+"M_1";
                selectedVal = (sZAT == "4") ? "" : $(formCommDiv).find(selectNm).val();
            }
        } 
    }
       
    $(dailyTr).find("select[name="+type+"]").find("option[value='"+selectedVal+"']").prop("selected",true)
}

function markEtc(param){
    var formCommDiv = "#formCommDiv_"+param.changeFlag;
    var formDetailDiv = "#formDetailDiv_"+param.changeFlag;

    var vFAMID = ("APPLY" == param.ACTION)? "" : $(formCommDiv).find(".vFAMID").val();
    var vWEEKNUM = ("APPLY" == param.ACTION) ? "" : $(formCommDiv).find(".vWEEKNUM").val();
    var vWEEKSUM = ("APPLY" == param.ACTION) ? "" : $(formCommDiv).find(".vWEEKSUM").val();
    $(formDetailDiv).find(".sFAMTY option[objps='"+vFAMID+"']").prop("selected", true);
    $(formDetailDiv).find(".oWEEKNUM").val(vWEEKNUM);
    $(formDetailDiv).find(".oWEEKSUM").val(vWEEKSUM);
}
// 이용 가능
function fn_detailAttrEnabled_${reqParam.changeFlag}(param){
    var formDetailDiv = "#formDetailDiv_"+param.changeFlag;
    $(formDetailDiv).find("select").prop("disabled", false);
    $(formDetailDiv).find(".oAPNOTE").prop("disabled", false);
    
    $($(formDetailDiv).find(".dailyTr")).each(function(){
        var sZAT = $(this).find(".sZAT option:selected").val();
        
        if(sZAT == '4'){
            $(this).find("select[class^='sHM']").prop("disabled", true);
        }
    })

}

// 이용 불가능
function fn_detailAttrDisabled_${reqParam.changeFlag}(){
    var formDetailDiv = "#formDetailDiv_"+param.changeFlag;
    $(formDetailDiv).find("select").prop("disabled", true);
    if(param.ACTION == 'UPDATE' && $("#iCANFLG_after").prop("checked")){
        $(formDetailDiv).find(".oAPNOTE").prop("disabled", false);
    }else{
        $(formDetailDiv).find(".oAPNOTE").prop("disabled", true);
    }
}

//근무구분 선택
$("#formDetailDiv_${reqParam.changeFlag} .sZAT").change(function(){
    var dailyTr = $(this).parents(".dailyTr");
    $(dailyTr).find("select[class^='sHM']").prop("disabled",false);
    $(dailyTr).find(".oARS").val("");
    $(dailyTr).find(".oARS_1").val("");
            
    var value = $(this).find("option:selected").val();
    if(value == 4){ // 통상근무
        dailyTr.find("select[class^='sHM']").prop("disabled",true);
        dailyTr.find("select[class^='sHM'] option[value='']").prop("selected",true);
    }
    var workTime = getWorkTime(dailyTr, param); //근무시간 
    setWorkTime(dailyTr, workTime);
    var workTime1 = getWorkTime1(dailyTr, param); //근무시간 
    setWorkTime1(dailyTr, workTime1);

    markWeeklyWorkTime(param)
})
        
// // 시간 선택 
$("#formDetailDiv_${reqParam.changeFlag} .sHM").change(function(){
    var dailyTr = $(this).parents(".dailyTr");
    var sZAT = nvl($(dailyTr).find(".sZAT option:selected").val(), "");
    setWorkTime(dailyTr, '');
    
    if(sZAT != "5"){
    	return;
    }
    
    //근무시간은 무조건 8시간 
    var sBEZ_C = nvl($(dailyTr).find(".sBEZ_C option:selected").val(), "");
    var sBEZ_M = nvl($(dailyTr).find(".sBEZ_M option:selected").val(), "");
    var sENZ_C = nvl($(dailyTr).find(".sENZ_C option:selected").val(), "");
    var sENZ_M = nvl($(dailyTr).find(".sENZ_M option:selected").val(), "");
        
    if(sBEZ_C == '' || sBEZ_M == '' || sENZ_C == '' || sENZ_M == '' ){
    	markWeeklyWorkTime(param);
        return;
    }
    
    if(getRestTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M, param.zlcty) > 0 ){ //점심시간 예외처리
        markWeeklyWorkTime(param);
    	alert("점심시간은 선택할 수 없습니다.")
        return ;
    }
    var workTime = calcWorkTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M) ;
    setWorkTime(dailyTr, workTime);

    markWeeklyWorkTime(param);
    if(workTime > 2){
        alert("육아시간은 2시간을 초과할 수 없습니다")
    }
})
// // 시간 선택 
$("#formDetailDiv_${reqParam.changeFlag} .sHM_1").change(function(){
    var dailyTr = $(this).parents(".dailyTr");
    var sZAT = nvl($(dailyTr).find(".sZAT option:selected").val(), "");
    setWorkTime1(dailyTr, '');
    
    if(sZAT != "5"){
    	return;
    }
    
    //근무시간은 무조건 8시간 
    var sBEZ_C_1 = nvl($(dailyTr).find("select[name='sBEZ_C_1'] option:selected").val(), "");
    var sBEZ_M_1 = nvl($(dailyTr).find("select[name='sBEZ_M_1'] option:selected").val(), "");
    var sENZ_C_1 = nvl($(dailyTr).find("select[name='sENZ_C_1'] option:selected").val(), "");
    var sENZ_M_1 = nvl($(dailyTr).find("select[name='sENZ_M_1'] option:selected").val(), "");
    if(sBEZ_C_1 == '' || sBEZ_M_1 == '' || sENZ_C_1 == '' || sENZ_M_1 == '' ){
        markWeeklyWorkTime(param);
        return;
    }

    if(getRestTime(sBEZ_C_1, sBEZ_M_1, sENZ_C_1, sENZ_M_1, param.zlcty) > 0 ){ //점심시간 예외처리
    	markWeeklyWorkTime(param);
        alert("점심시간은 선택할 수 없습니다.")
        return ;
    }
    var workTime1 = calcWorkTime(sBEZ_C_1, sBEZ_M_1, sENZ_C_1, sENZ_M_1) ;
    setWorkTime1(dailyTr, workTime1);
    
    markWeeklyWorkTime(param);
    if(workTime1 > 2){
        alert("육아시간은 2시간을 초과할 수 없습니다")
    }
})
        
$("#formDetailDiv_${reqParam.changeFlag} .sFAMTY").change(function(){
   
   var dataObj = new Object();
   dataObj.iFAMID = nvl($("#formDetailDiv_after").find(".sFAMTY option:selected").attr("objps"), "");
   dataObj.iFLWNO = document.saveForm.iFLWNO.value;
   dataObj.iBEGDA = nvl($("input[name='oBEGDA_after']").val().replace(/\./gi, ""), "");
   
   
   getAccumulastedWeek(dataObj);
   
})

$('#oBEGDA_${reqParam.changeFlag}, #oENDDA_${reqParam.changeFlag}').on('hide', function (){
	var weekCnt = getWeekCnt();
    $("#formDetailDiv_after").find(".oWEEKNUM").val(weekCnt);
});

<c:if test ="${reqParam.ACTION eq 'APPLY' || (reqParam.ACTION eq 'UPDATE' && reqParam.changeFlag eq 'after') || (reqParam.ACTION eq 'ENDAPPLY' && reqParam.changeFlag eq 'after')}">
function saveChk_byType(){
    var flag = false;
    
    var formCommDiv = "#formCommDiv_after";
    var formDetailDiv = "#formDetailDiv_after";
    var iBEGDA = $(formCommDiv).find("input[name='oBEGDA_after']").val().replace(/\./gi, "-"); //기간 -시작
    var iENDDA = $(formCommDiv).find("input[name='oENDDA_after']").val().replace(/\./gi, "-"); //기간 -종료
//     var iWOSTD = nvl($("#formCommDiv_after .workTimeWeek").find("input[type=text]").val(), "") // 주간근무시간
//     var wostd = $("#sTMDTY_after option:selected").attr("wostd").trim(); //주간근무시간
//     var sENZ_C = nvl($("#timeSettingTable").find(".sENZ_C option:selected").val(), "");
//     var sENZ_M = nvl($("#timeSettingTable").find(".sENZ_M option:selected").val(), "");
    if(isParentingTimeStatus()){// 육아시간 가능여부 체크 
    	flag = true;
    	return flag;
    }
    
    var sFAMTY = nvl($(formDetailDiv).find("select[name='sFAMTY'] option:selected").val(),"");
    if(sFAMTY == ""){   //선택된 자녀가 없으면 알람
    	alert("자녀를 선택해주세요")
    	flag = true;
    	return flag;
    }
    
    if(new Date(iBEGDA).getDay() != 1){ //유연근무제 시작일은 월요일
    	cfAlertMsg("유연근무제 시작일은 월요일만 가능합니다");
    	flag = true;
    	return flag;
    }
    if(new Date(iENDDA).getDay() != 0){ //유연근무제 종료일은 일요일
    	cfAlertMsg("유연근무제 종료일은 일요일만 가능합니다.");
    	flag = true;
    	return flag;
    }
    
    return flag;
}

function isParentingTimeStatus(){
	var flag = false;
	var formDetailDiv_after = "#formDetailDiv_after";
	var workTimeWeek = nvl($("#formDetailDiv_after workTimeWeek").find("input").val(), "");
	if(Number(workTimeWeek) > 10){
		alert("육아시간은 1일 최대 2시간, 1주 최대 10시간 사용가능합니다")
		flag = true;
		return flag;
	}
	
	var parentingTimeCnt = 0 ;
	$("#formDetailDiv_after").find(".dailyTr").each(function(idx){
		var date = nvl($(this).find("th").text() ,"");
		var sZAT = nvl($(this).find(".sZAT option:selected").val(), "");
		var oARS = nvl($(this).find(".oARS").val(), "");
		var oARS1 = nvl($(this).find(".oARS_1").val(), "");
		var sBEZ_C = nvl($(this).find("select[name=sBEZ_C] option:selected").val(), "");
		var sBEZ_M = nvl($(this).find("select[name=sBEZ_M] option:selected").val(), "");
		var sENZ_C = nvl($(this).find("select[name=sENZ_C] option:selected").val(), "");
		var sENZ_M = nvl($(this).find("select[name=sENZ_M] option:selected").val(), "");
		var sBEZ_C1 = nvl($(this).find("select[name=sBEZ_C_1] option:selected").val(), "");
		var sBEZ_M1 = nvl($(this).find("select[name=sBEZ_M_1] option:selected").val(), "");
		var sENZ_C1 = nvl($(this).find("select[name=sENZ_C_1] option:selected").val(), "");
		var sENZ_M1 = nvl($(this).find("select[name=sENZ_M_1] option:selected").val(), "");
		
		var sBEZ  = "".concat(sBEZ_C, sBEZ_M)
		var sENZ  = "".concat(sENZ_C, sENZ_M)
		var sBEZ1 = "".concat(sBEZ_C1, sBEZ_M1)
		var sENZ1 = "".concat(sENZ_C1, sENZ_M1)
		
		if(sZAT == "5"){
			var time = Number(oARS) + Number(oARS1);
			if(time > 2 ){
				alert("육아시간은 1일 최대 2시간, 1주 최대 10시간 사용가능합니다")
				flag = true;
				return false;
			}else if(getRestTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M, param.zlcty) > 0 || getRestTime(sBEZ_C1, sBEZ_M1, sENZ_C1, sENZ_M1, param.zlcty) > 0 ){ //점심시간 예외처리
				alert("점심시간은 선택할 수 없습니다.")
				flag = true;
				return false;
			}else if(oARS.slice(-2) == '50' || oARS1.slice(-2) == '50'){
				alert("육아시간은 시간단위로만 입력가능합니다.")
				flag = true;
				return false;
			}
			
			parentingTimeCnt ++ ;
		}
		
		if($("#formDetailDiv_after").find(".dailyTr").length-1 == idx && parentingTimeCnt == 0){
			alert("육아시간을 선택해주십시요.")
			flag = true;
			return false;
		}
	})
	
	return flag;
}

function getWeekCnt(){
    if($("#oBEGDA_after").val() == '' || $("#oENDDA_after").val() == ''){
    	return "";
    }
	var begdaDt = new Date($("#oBEGDA_after").val());
    var enddaDt = new Date($("#oENDDA_after").val());
    
    var diffDate = (enddaDt.getTime() - begdaDt.getTime()) / (1000 * 60 * 60 * 24); // 일수 차이
	var weekCnt = Math.ceil(diffDate / 7);
    
    return weekCnt ;
}

function getAccumulastedWeek(dataObj){
	if(dataObj.iFAMID == ''){
		$("#formDetailDiv_after").find(".oWEEKSUM").val('');
		$("#formDetailDiv_after").find(".oWEEKNUM").val('');
		return;
	}else{
		var weekCnt = getWeekCnt();
		$("#formDetailDiv_after").find(".oWEEKNUM").val(weekCnt);
	}
   
	$("#formDetailDiv_after .sFAMTY").attr("disabled", true);
	
	$.ajax({
	       url: "/ess/pa.getAccumulastedWeek.do",
	       type: "post",
	       dataType: "json",
	       data : dataObj,
	       async: true,
	       success:function(result) {
	           console.log(result)
	           $("#formDetailDiv_after").find(".oWEEKSUM").val(result.EV_WEEKSUM);
	           
	       },
	       error : function(request, status, error) {
	           cfAlertMsg("오류가 발생하였습니다.");
	       },
	}).always(function(){
	    $("#formDetailDiv_after .sFAMTY").attr("disabled", false);
    })
}

// $("#oBEGDA_after, #oENDDA_after").off().on("change", function(e){
// 	e.stopPropagation();
// 	var sFLWTY_after = nvl($("#formCommDiv_after #sFLWTY_after option:selected").val(), "");
	
// 	if(sFLWTY_after != "80"){
// 		return;
// 	}
//     var iBEGDA = $("input[name='oBEGDA_after']").val().replace(/\./gi, "-"); //기간 -시작
//     var iENDDA = $("input[name='oENDDA_after']").val().replace(/\./gi, "-"); //기간 -종료
//     console.log(iBEGDA, iENDDA)
//     if(iBEGDA == "" || iENDDA == ""){
//     	return;
//     }
    
//     var weekDiff =  new Date(iENDDA).getWeek() - new Date(iBEGDA).getWeek();
// 	$("#formDetailDiv_after .oWEEKNUM").val(weekDiff)
// })
</c:if>
</script>

<style>
    table.table_st01 input[type='text']{min-width:50px !important;}
</style>


<div class="timeSelectDiv" style="display: flex;">
    <c:choose>
        <c:when test="${(reqParam.ACTION eq 'DETAIL' && reqParam.endApplyYn eq 'Y' && reqParam.changeFlag eq 'after') || (reqParam.ACTION eq 'ENDAPPLY' && reqParam.changeFlag eq 'after')}">
            <table class="table_st01 tableW700">
                <colgroup>
                    <col width="200">    <!-- 유연근무제 기간 -->
                    <col width="*">    <!-- 입력란 -->
                </colgroup>
                <tbody>
                    <tr>
                        <th>유연근무제 기간</th>
                        <td>
                            <ul class="calendar_wrap">
                                <li class="calendar">
                                    <c:set var="BEGDA_NM" value ="oBEGDA_${reqParam.changeFlag}"/>
                                    <fmt:formatDate var="oBEGDA_Comm" value="${result.BEGDA}" pattern="yyyy.MM.dd" />
                                    <input type="text" name="${BEGDA_NM}" id="${BEGDA_NM}" value="${oBEGDA_Comm}"/><label for="${BEGDA_NM}" onclick="$.showCal2('${BEGDA_NM}')" style="vertical-align:top;">달력</label>
                                </li>
                                <li class="wave">~</li>
                                <li class="calendar">
                                    <c:set var="ENDDA_NM" value ="oENDDA_${reqParam.changeFlag}"/>
<%--                                     <fmt:formatDate var="oENDDA_Comm" value="${now}" pattern="yyyy.MM.dd" /> --%>
<%--                                     <input type="text" name="${ENDDA_NM}" id="${ENDDA_NM}" value="${oENDDA_Comm}"/><label for="${ENDDA_NM}" onclick="$.showCal2('${ENDDA_NM}')" style="vertical-align:top;">달력</label> --%>
                                    <input type="text" name="${ENDDA_NM}" id="${ENDDA_NM}" value=""/><label for="${ENDDA_NM}" onclick="$.showCal2('${ENDDA_NM}')" style="vertical-align:top;">달력</label>
                                </li>
                            </ul>
                        </td>
                    </tr>
                    <tr>
                        <th>종료신청사유</th>
                        <td>
                           <input type="text" class="oAPNOTE" value= ""/>
                        </td>
                    </tr>
                </tbody>
            </table>
            <div style="width:300px; margin:0px 0 auto auto;">
                <table class="table_st01">
                    <tbody>
                        <tr style="display:none;">
                            <th>자녀선택</th>
                            <td style="text-align: center;">
                                <select name="sFAMTY" class="select sFAMTY sForm" >
                                    <option></option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th>신청주수</th>
                            <td style="text-align: center;">
                                <input type="text" class="oWEEKNUM" value= "" disabled/>
                            </td>
                        </tr>
                        <tr>
                            <th>기누적사용</th>
                            <td style="text-align: center;">
                                <input type="text" class="oWEEKSUM" value= "" disabled/>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <table class="table_st01 tableW700">
                <colgroup>
                    <col width="30">    <!-- 요일 -->
                    <col width="120">   <!-- 근무구분 -->
                    <col width="200">   <!-- 시작 -->
                    <col width="200">   <!-- 종료 -->
                    <col width="*">  <!-- 근무시간 -->
                </colgroup>
                <thead>
                    <tr>
                        <th></th>
                        <th>근무구분</th>
                        <th>시작</th>
                        <th>종료</th>
                        <th>육아시간</th>
                    </tr>
                </thead>
                <tbody>
                    <c:set var="dayText" value=""/>
                    <c:forEach var="item" begin="1" end="5" varStatus="status">
                    <c:choose>
                        <c:when test="${status.index eq '1'}"><c:set var="dayText" value="월"/></c:when>
                        <c:when test="${status.index eq '2'}"><c:set var="dayText" value="화"/></c:when>
                        <c:when test="${status.index eq '3'}"><c:set var="dayText" value="수"/></c:when>
                        <c:when test="${status.index eq '4'}"><c:set var="dayText" value="목"/></c:when>
                        <c:when test="${status.index eq '5'}"><c:set var="dayText" value="금"/></c:when>
                    </c:choose>
                    <tr class="dailyTr">
                        <th>${dayText}</th>
                        <td>
                            <div class="select_wrap" style="text-align:center;">
                                <select name="sZAT" class="select sZAT sForm"  >
                                    <option value="">선택하세요</option> 
                                </select>
                            </div>
                        </td>
                        <td>
                            <ul class="calendar_wrap" style="margin-bottom:1px">
                                <li class="">
                                    <select name="sBEZ_C" class="sHM sBEZ_C sForm" >
                                              <option></option>
                                    </select>
                                </li>
                                <li class="wave">시</li>
                                <li class="">
                                    <select name="sBEZ_M" class="sHM sBEZ_M sForm">
                                        <option></option>
                                    </select>
                                </li>
                                <li class="wave">분</li>
                                <li class="wave">~</li>
                            </ul>
                            <ul class="calendar_wrap">
                                <li class="">
                                    <select name="sBEZ_C_1" class="sHM_1 sBEZ_C sForm" >
                                              <option></option>
                                    </select>
                                </li>
                                <li class="wave">시</li>
                                <li class="">
                                    <select name="sBEZ_M_1" class="sHM_1 sBEZ_M sForm">
                                        <option></option>
                                    </select>
                                </li>
                                <li class="wave">분</li>
                                <li class="wave">~</li>
                            </ul>
                        </td>
                        <td>
                            <ul class="calendar_wrap" style="margin-bottom:1px">
                                <li class="">
                                    <select name="sENZ_C" class="sHM sENZ_C sForm">
                                        <option></option>
                                    </select>
                                </li>
                                <li class="wave">시</li>
                                <li class="">
                                    <select name="sENZ_M" class="sHM sENZ_M sForm">
                                        <option></option>
                                    </select>
                                 </li>
                                 <li class="wave">분</li>
                            </ul>
                            <ul class="calendar_wrap">
                                <li class="">
                                    <select name="sENZ_C_1" class="sHM_1 sENZ_C sForm">
                                        <option></option>
                                    </select>
                                </li>
                                <li class="wave">시</li>
                                <li class="">
                                    <select name="sENZ_M_1" class="sHM_1 sENZ_M sForm">
                                        <option></option>
                                    </select>
                                 </li>
                                 <li class="wave">분</li>
                            </ul>
                        </td>
                        <td style="text-align:center;">
                            <input type="text" class="oARS" value= "" disabled/>
                            <input type="text" class="oARS_1" value= "" disabled/>
                        </td>
                    </tr>
                    </c:forEach>
                    <tr>
<!--                        <th colspan="2" style="text-align:left; padding-left:20px !important;">신청사유</th> -->
                        <th colspan="2" class="oAPNOTE_TH">
                            <c:choose>
                               <c:when test="${reqParam.ACTION eq 'DETAIL'}" >
                                   <c:choose>
                                       <c:when test="${reqParam.changeFlag eq 'before' && reqParam.endApplyYn eq 'Y'}">종료신청 사유</c:when>
                                       <c:when test="${reqParam.changeFlag eq 'before' && reqParam.updateOldYn eq 'Y'}">변경사유</c:when>
                                       <c:when test="${reqParam.changeFlag eq 'after' && reqParam.endApplyYn eq 'Y'}">종료신청 사유</c:when>
                                       <c:when test="${reqParam.changeFlag eq 'after' && reqParam.updateOldYn eq 'Y'}">변경사유</c:when>
                                       <c:otherwise>신청사유</c:otherwise>
                                   </c:choose>
                               </c:when>
                               <c:when test="${reqParam.ACTION eq 'UPDATE'}" >
                                   <c:choose>
                                       <c:when test="${reqParam.changeFlag eq 'before' && reqParam.endApplyYn eq 'Y'}">종료신청 사유</c:when>
                                       <c:when test="${reqParam.changeFlag eq 'before' && reqParam.updateOldYn eq 'Y'}">변경사유</c:when>
                                       <c:when test="${reqParam.changeFlag eq 'after'}">변경사유</c:when>
                                       <c:otherwise>신청사유 </c:otherwise>
                                   </c:choose>
                               </c:when>
                               <c:when test="${reqParam.ACTION eq 'ENDAPPLY'}" >
                                   <c:choose>
                                       <c:when test="${reqParam.changeFlag eq 'before' && reqParam.updateOldYn eq 'Y'}">변경사유</c:when>
                                       <c:when test="${reqParam.changeFlag eq 'after'}">종료신청 사유</c:when>
                                       <c:otherwise>신청사유 </c:otherwise>
                                   </c:choose>
                               </c:when>
                               <c:otherwise>신청사유 </c:otherwise>
                            </c:choose>
                        </th>
                        <td colspan="3">
                            <input type="text" class="oAPNOTE" value= "" style="width:518px !important;"/>
                        </td>
                    </tr>
                </tbody>
            </table>
            <div style="width:300px; margin:50px 0 auto auto;">
                <table class="table_st01">
                    <tbody>
                        <tr>
                            <th>자녀선택</th>
                            <td style="text-align: center;">
                                <select name="sFAMTY" class="select sFAMTY sForm">
                                    <option></option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th>신청주수</th>
                            <td style="text-align: center;">
                                <input type="text" class="oWEEKNUM" value= "" disabled/>
                            </td>
                        </tr>
                        <tr>
                            <th>기누적사용</th>
                            <td style="text-align: center;">
                                <input type="text" class="oWEEKSUM" value= "" disabled/>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<c:if test="${reqParam.changeFlag eq 'after'}">
    <div class="text-danger" style="margin-bottom:20px;">
        <p>※육아시간 사용시 주의사항</p>
        <p> - 취업규칙 제12조의3 (육아시간등 ) ① 만 8세이하 또는 초등학교 2학년 이하의 자녀를 둔 직원은 36개월 범위 내에서 1일 최대 2시간의 육아시간을 받을 수 있다.</p>
        <p> - 출퇴근 전후, 점심시간(12:00~13:00) 전후로 활용가능</p>
        <p> - 1일 2시간, 1주 최대 10시간 사용가능</p>
        <p> - 육아시간은 단위부서장(사업소장 및 본사 처장)까지 결재 올림</p>
        <p> - 자녀 생년월일 확인이 가능한 증빙 첨부 필수(가족관계증명서, 주민등록등본 등)</p>
    </div>
</c:if>
