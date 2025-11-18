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
                selectNm = ".v"+type.substr(1,3)+"0"+(idx+1)+"M";
                selectedVal = $(formCommDiv).find(selectNm).val();
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

// 이용 가능
function fn_detailAttrEnabled_${reqParam.changeFlag}(param){
    var formDetailDiv = "#formDetailDiv_"+param.changeFlag;
    
    $(formDetailDiv).find("select").prop("disabled", false);
    $(formDetailDiv).find(".oAPNOTE").prop("disabled", false);
    
    $(formDetailDiv).find(".dailyTr").each(function(idx){
        $(this).find(".sZAT").prop("disabled", true)
        $(this).find("[class*='sENZ']").prop("disabled", true)
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


// 시작 분 선택
$("#formDetailDiv_${reqParam.changeFlag} [class*='sBEZ']").change(function(){
    var dailyTr = $(this).parents(".dailyTr");
    var sBEZ_C = nvl($(dailyTr).find(".sBEZ_C option:selected").val(),"");
    var sBEZ_M = nvl($(dailyTr).find(".sBEZ_M option:selected").val(),"");

    if(sBEZ_C =="" || sBEZ_M==""){
	    $(dailyTr).find(".oARS").val("");
        $(dailyTr).find(".sENZ_C option[value='']").prop("selected",true)
        $(dailyTr).find(".sENZ_M option[value='']").prop("selected",true)
        markWeeklyWorkTime(param);
    	return 
    }
    if(sBEZ_C =="11" && sBEZ_M=="30"){
    	alert("시작시간은 07시부터 11시이내만 가능합니다.")
        $(dailyTr).find(".sENZ_C option[value='']").prop("selected",true)
        $(dailyTr).find(".sENZ_M option[value='']").prop("selected",true)
        return;
    }
    
    $(dailyTr).find(".oARS").val("");
    var sBEZ = "".concat(sBEZ_C, ".", (sBEZ_M == "30" ? "50":sBEZ_M))    
    console.log("sBEZ=>", sBEZ_C, sBEZ_M, sBEZ)
    
    var max = $("#sTMDTY_after option:selected").attr("max").trim();
    
    var sENZ = Number(sBEZ) + Number(max);
    var sENZ_C = String(sENZ).split('.')[0];
    sENZ_C = sENZ_C > 10 ? sENZ_C : fillZero(2,sENZ_C);
    var sENZ_M = String(sENZ).split('.')[1] == '5' ? '30': '00';
    
    var restTime = getRestTime(sBEZ_C, sBEZ_M, sENZ_C, sENZ_M); 
    sENZ = Number(sBEZ) + Number(max) + restTime;
    sENZ_C = String(sENZ).split('.')[0];
    sENZ_C = sENZ_C > 10 ? sENZ_C : fillZero(2,sENZ_C);
    sENZ_M = String(sENZ).split('.')[1] == '5' ? '30': '00';
    
    $(dailyTr).find(".sENZ_C option[value='"+sENZ_C+"']").prop("selected",true)
    $(dailyTr).find(".sENZ_M option[value='"+sENZ_M+"']").prop("selected",true)
    
    var workTime = getWorkTime(dailyTr, param); //근무시간 
    setWorkTime(dailyTr, workTime);
    
    markWeeklyWorkTime(param);
})

//근무구분 선택
$("#formDetailDiv_${reqParam.changeFlag} .sZAT").change(function(){
    var dailyTr = $(this).parents(".dailyTr");
    $(dailyTr).find(".sHM").prop("disabled",false);
    $(dailyTr).find(".oARS").val("");
    
    var value = $(this).find("option:selected").val();
    if(value == 1){ // 정상근무이면 
        dailyTr.find(".sHM").prop("disabled",true);
        dailyTr.find(".sBEZ_C option[value='09']").prop("selected",true);
        dailyTr.find(".sBEZ_M option[value='00']").prop("selected",true);
        dailyTr.find(".sENZ_C option[value='18']").prop("selected",true);
        dailyTr.find(".sENZ_M option[value='00']").prop("selected",true);
    }
    var workTime = getWorkTime(dailyTr, param); //근무시간 
    setWorkTime(dailyTr, workTime);

    markWeeklyWorkTime(param)
})
        

<c:if test ="${reqParam.ACTION eq 'APPLY' || (reqParam.ACTION eq 'UPDATE' && reqParam.changeFlag eq 'after') || (reqParam.ACTION eq 'ENDAPPLY' && reqParam.changeFlag eq 'after')}">
function saveChk_byType(){
    var flag = false;
    
    var alertMsg = "";
    var iWOSTD = nvl($("#formCommDiv_after .workTimeWeek").find("input[type=text]").val(), "") // 주간근무시간
    var wostd = $("#sTMDTY_after option:selected").attr("wostd").trim(); // 주어진 주간근무시간

    if(iWOSTD != wostd){
        flag = true;
        alertMsg="근무시간이 총 "+wostd+"시간이 되어야 합니다.";
    }
    
    if(flag){
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
        
        </c:otherwise>
    </c:choose>
</div>
