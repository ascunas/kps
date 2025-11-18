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
$(document).ready(function(){
	
    param.changeFlag ="${reqParam.changeFlag}";
    param.endApplyYn ="${reqParam.endApplyYn}";
    param.cancelYn ="${reqParam.cancelYn}";
    param.zlcty ="${reqParam.zlcty}";
    param.zlcod ="${reqParam.zlcod}";
    param.msgCode ="${reqParam.msgCode}";
    param.message ="${reqParam.message}";

    var formDiv =  "#formDiv_"+param.changeFlag;

    if(param.ACTION == "ENDAPPLY" && param.changeFlag == "after"){
        var begda = $(formDiv).find(".vBEGDA").val();
        $("#oBEGDA_after").val(begda);
        
        $("#oBEGDA_after").prop("disabled",true);
        $("#oBEGDA_after").siblings("label").css("display","none");
        return;
    } else if (param.ACTION == "DETAIL" && param.changeFlag == "after" && param.endApplyYn == 'Y'){
        var begda = $(formDiv).find(".vBEGDA").val();
        var endda = $(formDiv).find(".vENDDA").val();
        var vAPNOTE = $("#formCommDiv_after").find(".vAPNOTE").val();
        
        $("#oBEGDA_after").val(begda);
        $("#oENDDA_after").val(endda);
        $("#formDetailDiv_after").find('.oAPNOTE').val(vAPNOTE);
        
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
    appendOptions("sWKWDAY", param.changeFlag, getSelectOptions("sWKWDAY", param.changeFlag, param.zlcty, param.zlcod));

    // 결과값 셋팅
    var workDayWeek = 0;    //주간근무일수
    var workTimeWeek = 0;   //주간근무시간
    $(formDiv).find(".dailyTr").each(function(idx){
        
        // select-option selected 셋팅
        markOptionSelected(this, "sZAT", param);
        markOptionSelected(this, "sBEZ_C", param);
        markOptionSelected(this, "sBEZ_M", param);
        markOptionSelected(this, "sENZ_C", param);
        markOptionSelected(this, "sENZ_M", param);
        
        //근무시간
        var time = getWorkTime(this, param);
        setWorkTime(this, time);        

        var sZAT = $(this).find(".sZAT option:selected").val() ;
        workDayWeek += (sZAT != "" && sZAT != "3") ? 1 : 0;   //휴무일이 아니면 근무일
        workTimeWeek += Number(time);
    })
    
    if(param.ACTION == "APPLY" || (param.ACTION == "UPDATE" && param.changeFlag == "after") ){
        $(formDiv).find(".workDayWeek input[type=text]").val(workDayWeek.toFixed(2))
        $(formDiv).find(".workTimeWeek input[type=text]").val(workTimeWeek.toFixed(2))
    }
    
    markApNote(param); //신청사유 표시
    markEtc(param);
    
    //상태 표시
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
    var idx = $(dailyTr).index();
    var selectedVal, selectNm = "";
    if(param.ACTION == "APPLY" || (param.ACTION == "UPDATE" && param.initYn == "Y")){
        if(type == 'sZAT'){selectedVal = "2";} 
    } else {
        if(param.ACTION == 'DETAIL' || param.initYn == "N"){
            if(type == 'sZAT'){
                selectNm = ".v"+type.substr(1)+"0"+(idx+1);
                selectedVal = $(formCommDiv).find(selectNm).val();
            } else if (type == 'sBEZ_C' ){
                selectNm = ".v"+type.substr(1,3)+"0"+(idx+1)+"C";
                selectedVal = $(formCommDiv).find(selectNm).val();
            } else if (type == 'sBEZ_M' || type == 'sENZ_M'){
            	if($(dailyTr).find(".sZAT").val() !="3"){
	                selectNm = ".v"+type.substr(1,3)+"0"+(idx+1)+"M";
	                selectedVal = $(formCommDiv).find(selectNm).val();
            	}
            } else if (type == 'sENZ_C' ){
                selectNm = ".v"+type.substr(1,3)+"0"+(idx+1)+"C";
                selectedVal = $(formCommDiv).find(selectNm).val();
            } else {
                selectNm = ".v"+type.substr(1)+"0"+(idx+1);
                selectedVal = $(formCommDiv).find(selectNm).val();
            }
        }
    }
       
    $(dailyTr).find("."+type).find("option[value='"+selectedVal+"']").prop("selected",true)
}

function markEtc(param){
    var formCommDiv = "#formCommDiv_"+param.changeFlag;
    var formDetailDiv = "#formDetailDiv_"+param.changeFlag;

    // 변경신청시 기존선택 옵션 셋팅 
    if("UPDATE" == param.ACTION && "after" == param.changeFlag ){
    	if("Y" == param.initYn){
	        $(formDetailDiv).find(".sWKWDAY option[value='']").prop("selected",true)
	        $(formDetailDiv).find(".sBEZHOR option[value='']").prop("selected",true)
	        $(formDetailDiv).find(".sBEZMIN option[value='']").prop("selected",true)
	        $(formDetailDiv).find(".sENZHOR option[value='']").prop("selected",true)
	        $(formDetailDiv).find(".sENZMIN option[value='']").prop("selected",true)
	        $(formDetailDiv).find(".oARSTIM").val('');
    	}else{
	        var vWKWDAY = $(formCommDiv).find(".vWKWDAY").val();
	        var vBEZHOR = $(formCommDiv).find(".vBEZHOR").val();
	        var vBEZMIN = $(formCommDiv).find(".vBEZMIN").val();
	        var vENZHOR = $(formCommDiv).find(".vENZHOR").val();
	        var vENZMIN = $(formCommDiv).find(".vENZMIN").val();
	        var vARSTIM = $(formCommDiv).find(".vARSTIM").val();
	        
	        $(formDetailDiv).find(".sWKWDAY option[value='"+vWKWDAY+"']").prop("selected",true)
	        $(formDetailDiv).find(".sBEZHOR option[value='"+vBEZHOR+"']").prop("selected",true)
	        $(formDetailDiv).find(".sBEZMIN option[value='"+vBEZMIN+"']").prop("selected",true)
	        $(formDetailDiv).find(".sENZHOR option[value='"+vENZHOR+"']").prop("selected",true)
	        $(formDetailDiv).find(".sENZMIN option[value='"+vENZMIN+"']").prop("selected",true)
	        $(formDetailDiv).find(".oARSTIM").val(vARSTIM);
    	}
    }
}
// 이용 가능
function fn_detailAttrEnabled_${reqParam.changeFlag}(param){
    var formDetailDiv = "#formDetailDiv_"+param.changeFlag;
    
    $(formDetailDiv).find("select").prop("disabled", false);
    $(formDetailDiv).find(".oAPNOTE").prop("disabled", false);
    
    $(formDetailDiv).find("#timeSettingTable [class*='sENZ']").prop("disabled", true);
    
    $(formDetailDiv).find(".dailyTr").each(function(idx){
//         $(this).find(".sZAT").prop("disabled", true)
        $(this).find(".sHM").prop("disabled", true)
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

// 주간근무일수 선택
$("#formDetailDiv_${reqParam.changeFlag} #timeSettingTable .sWKWDAY").change(function(){
    var hmObj = getTimeHm(param.zlcty);
    console.log(hmObj);
    
    //주간근무일수에 따른 종료일 셋팅
    var timeSettingTable = $("#formDetailDiv_after").find("#timeSettingTable");
    $(timeSettingTable).find(".sENZ_C option[value='"+hmObj.sENZ_C+"']").prop("selected",true)
    $(timeSettingTable).find(".sENZ_M option[value='"+hmObj.sENZ_M+"']").prop("selected",true)     
    $(timeSettingTable).find(".oARS").val(calcWorkTime(hmObj.sBEZ_C, hmObj.sBEZ_M, hmObj.sENZ_C, hmObj.sENZ_M, param.zlcty));
    
    // 요일별 셋팅 
    var dailyTr = $("#formDetailDiv_after").find(".dailyTr");
   	$(dailyTr).each(function(){
//    	    $(this).find(".sZAT").val('2');
    	$(this).find(".sZAT option[value='2']").prop("selected",true);
	    if(hmObj.sBEZ_C == "" || hmObj.sBEZ_M == ""){
	        $(this).find(".sHM option[value='']").prop("selected", true);
	        $(this).find(".oARS").val("");
	    }else{
	         $(this).find(".sBEZ_C option[value='"+hmObj.sBEZ_C+"']").prop("selected",true)
	         $(this).find(".sBEZ_M option[value='"+hmObj.sBEZ_M+"']").prop("selected",true)
	         $(this).find(".sENZ_C option[value='"+hmObj.sENZ_C+"']").prop("selected",true)
	         $(this).find(".sENZ_M option[value='"+hmObj.sENZ_M+"']").prop("selected",true)
	         $(this).find(".oARS").val(calcWorkTime(hmObj.sBEZ_C, hmObj.sBEZ_M, hmObj.sENZ_C, hmObj.sENZ_M, param.zlcty));
	    }
   	})
    markWeeklyWorkTime(param);
	
})

// 시작 분 선택
$("#formDetailDiv_${reqParam.changeFlag} #timeSettingTable .sHM").change(function(){
	var hmObj = getTimeHm(param.zlcty);
    
    if(hmObj.sWKWDAY=="" || hmObj.sBEZ_C =="" || hmObj.sBEZ_M==""){
        return ;
    }
	
    if(Number(hmObj.sENZ) > 18){
    	alert("종료시각은 18시 이내만 가능합니다.")
    }
    
    var timeSettingTable = $("#formDetailDiv_after").find("#timeSettingTable");
    if(Number(hmObj.sENZ_C) > 18.5){
	    $(timeSettingTable).find("[class*='sENZ'] option[value='']").prop("selected",true)
	    sENZ_C = $(timeSettingTable).find(".sENZ_M option:selected").val();
	    sENZ_M = $(timeSettingTable).find(".sENZ_M option:selected").val();
	    $(timeSettingTable).find(".oARS").val(calcWorkTime(hmObj.sBEZ_C, hmObj.sBEZ_M, hmObj.sENZ_C, hmObj.sENZ_M, param.zlcty));
    }else{
	    $(timeSettingTable).find(".sENZ_C option[value='"+hmObj.sENZ_C+"']").prop("selected",true)
	    $(timeSettingTable).find(".sENZ_M option[value='"+hmObj.sENZ_M+"']").prop("selected",true)
	    $(timeSettingTable).find(".oARS").val(calcWorkTime(hmObj.sBEZ_C, hmObj.sBEZ_M, hmObj.sENZ_C, hmObj.sENZ_M, param.zlcty));
    }
    
    $("#formDetailDiv_after .dailyTr").each(function(idx){
        $(this).find(".sZAT option[value='2']").prop("selected",true)
        if(hmObj.sENZ_C >= 19){
	        $(this).find(".sENZ_C option[value='']").prop("selected",true)
	        $(this).find(".sENZ_M option[value='']").prop("selected",true)
	        $(this).find(".oARS").val('');
        }else{
	        $(this).find(".sBEZ_C option[value='"+hmObj.sBEZ_C+"']").prop("selected",true)
	        $(this).find(".sBEZ_M option[value='"+hmObj.sBEZ_M+"']").prop("selected",true)
	        $(this).find(".sENZ_C option[value='"+hmObj.sENZ_C+"']").prop("selected",true)
	        $(this).find(".sENZ_M option[value='"+hmObj.sENZ_M+"']").prop("selected",true)
	        $(this).find(".oARS").val(calcWorkTime(hmObj.sBEZ_C, hmObj.sBEZ_M, hmObj.sENZ_C, hmObj.sENZ_M, param.zlcty));
        }
    })
    markWeeklyWorkTime(param);
})

//근무구분 선택
$("#formDetailDiv_${reqParam.changeFlag} .sZAT").change(function(){
    var hmObj = getTimeHm(param.zlcty);
    var dailyTr = $(this).parents(".dailyTr");
    
    var sZAT = $(this).find("option:selected").val();
    if(sZAT == "2"){ // 유연근무
	    var sBEZ_C = nvl($(timeSettingTable).find(".sBEZ_C option:selected").val(), "");
	    var sBEZ_M = nvl($(timeSettingTable).find(".sBEZ_M option:selected").val(), "");
	    var sENZ_C = nvl($(timeSettingTable).find(".sENZ_C option:selected").val(), "");
	    var sENZ_M = nvl($(timeSettingTable).find(".sENZ_M option:selected").val(), "");

	    dailyTr.find(".sBEZ_C option[value='"+hmObj.sBEZ_C+"']").prop("selected",true);
        dailyTr.find(".sBEZ_M option[value='"+hmObj.sBEZ_M+"']").prop("selected",true);
        dailyTr.find(".sENZ_C option[value='"+hmObj.sENZ_C+"']").prop("selected",true);
        dailyTr.find(".sENZ_M option[value='"+hmObj.sENZ_M+"']").prop("selected",true);
        dailyTr.find(".oARS").val(calcWorkTime(hmObj.sBEZ_C, hmObj.sBEZ_M, hmObj.sENZ_C, hmObj.sENZ_M, param.zlcty));
    }else if(sZAT == "3"){ // 휴무일
        dailyTr.find("[class*='sHM'] option[value='']").prop("selected",true);
        dailyTr.find(".oARS").val("");
    }
    
    markWeeklyWorkTime(param);
})
      
<c:if test ="${reqParam.ACTION eq 'APPLY' || (reqParam.ACTION eq 'UPDATE' && reqParam.changeFlag eq 'after') || (reqParam.ACTION eq 'ENDAPPLY' && reqParam.changeFlag eq 'after')}">
function saveChk_byType(){
    var flag = false;
    var alertMsg = "";
    var iBEGDA = nvl($("input[name='oBEGDA_after']").val().replace(/\./gi, ""), ""); //기간 -시작
    var iENDDA = nvl($("input[name='oENDDA_after']").val().replace(/\./gi, ""), ""); //기간 -종료
    var iWOSTD = nvl($("#formCommDiv_after .workTimeWeek").find("input[type=text]").val(), "") // 주간근무시간
    var wostd = $("#sTMDTY_after option:selected").attr("wostd").trim(); //주간근무시간
    var sENZ_C = nvl($("#timeSettingTable").find(".sENZ_C option:selected").val(), "");
    var sENZ_M = nvl($("#timeSettingTable").find(".sENZ_M option:selected").val(), "");
    
    if(iBEGDA =="" || iENDDA==""){
    	alertMsg="유연근무제 기간을 선택해주세요"
    }else if(iBEGDA.slice(-2) != "16"){
    	alertMsg="시작일은 매월 16일만 가능합니다"
    }else if(iENDDA.slice(-2) != "15"){
    	alertMsg="종료일은 매월 15일만 가능합니다"
    }else if(iWOSTD != wostd){
    	alertMsg="근무시간이 총 "+wostd+"시간이 되어야 합니다.";
    }else if(Number("".concat(sENZ_C,sENZ_M)) > 1800){
    	alertMsg="종료시각은 18시 이내만 가능합니다";
    }
    
    if(alertMsg != "" ){
    	flag = true;
        cfAlertMsg(alertMsg);
    }
    return flag;
}
</c:if>

</script>

<style>
    table.table_st01 input[type='text']{min-width:50px !important;}
</style>


<div class="timeSelectDiv" >
    <c:choose>
        <c:when test="${(reqParam.ACTION eq 'DETAIL' && reqParam.endApplyYn eq 'Y' && reqParam.changeFlag eq 'after') || (reqParam.ACTION eq 'ENDAPPLY' && reqParam.changeFlag eq 'after')}">
            <table class="table_st01 tableW700" >
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
        </c:when>
        <c:otherwise>
            <c:if test="${reqParam.ACTION eq 'APPLY' || (reqParam.ACTION eq 'UPDATE' && param.changeFlag eq 'after')}">
                <table class="table_st01 tableW700" id="timeSettingTable">
	                <colgroup>
	                    <col width="150">    <!-- 주간근무일수 -->
	                    <col width="200">   <!-- 시작 -->
	                    <col width="200">   <!-- 종료 -->
	                    <col width="*">  <!-- 근무시간 -->
	                </colgroup>
	                <thead>
	                    <tr>
	                        <th>주간근무일수</th>
	                        <th>시작</th>
	                        <th>종료</th>
	                        <th>근무시간</th>
	                    </tr>
	                </thead>
	                <tbody>
	                   <tr>
	                        <td style="text-align: center;">
                                <select name="sWKWDAY" class="select sWKWDAY sForm" >
                                    <option></option>
                                </select>
	                        </td>
	                        <td style="text-align: center;">
                                <select name="sBEZ_C" class="sHM sBEZ_C sForm sBEZHOR"></select>
                                <span>시</span>
                                <select name="sBEZ_M" class="sHM sBEZ_M sForm sBEZMIN"></select>
                                <span>분</span>
	                        </td>
	                        <td style="text-align: center;">
                                <select name="sENZ_C" class="sHM sENZ_C sForm sENZHOR"></select>
                                <span>시</span>
                                <select name="sENZ_M" class="sHM sENZ_M sForm sENZMIN"></select>
                                <span>분</span>
	                        </td>
	                        <td style="text-align:center; position:relative;">
	                            <input type="text" class="oARS oARSTIM" value= "" disabled/>
	                            <span style="top:10px; width:350px; position: absolute; color:blue;">※ 일 근무시간이 4시간 초과 시, 휴게시간 60분 부여</span>
	                        </td>
	                   </tr>
                    </tbody>
                </table>
                
            </c:if>
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
                        <th>근무시간</th>
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
                            <ul class="calendar_wrap">
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
                        </td>
                        <td>
                            <ul class="calendar_wrap">
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
                        </td>
                        <td style="text-align:center;">
                            <input type="text" class="oARS" value= "" disabled/>
                        </td>
                    </tr>
                    </c:forEach>
                    <tr>
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
        
        </c:otherwise>
    </c:choose>
</div>
