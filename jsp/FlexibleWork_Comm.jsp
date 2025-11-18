<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%-- <%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%> --%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="result" value="" />     <!-- 변경전/후 데이터-->
<c:set var="changeText" value="" />

<c:choose>
    <c:when test="${param.changeFlag eq 'before'}">
        <c:set var="result" value="${E_RESULT_OLD}" />
        <c:if test="${reqParam.ACTION eq 'UPDATE' || reqParam.ACTION eq 'ENDAPPLY'}">
            <c:set var="result" value="${E_RESULT}" />
        </c:if>
        <c:set var="changeText" value="변경전" />
    </c:when>
    <c:when test="${param.changeFlag eq 'after'}">
        <c:set var="result" value="${E_RESULT}" />
        <c:set var="changeText" value="변경후" />
    </c:when>
</c:choose>

<script>

$(document).ready(function(){
	param = {
	        "ACTION" : "${reqParam.ACTION}",
	        "changeFlag" : "${param.changeFlag}",
	        "initYn" : "N", //근무세부유형 초기화 여부
	        "titleUseYn" : "${param.titleUseYn}", //변경전,변경후  보이면 Y 
	        "updateOldYn" : "${result.ZWFKEY_OLD}" != "" ? "Y" : "N", //데이터 변경여부(변경된 경우 Y)
	        "endApplyYn" : "${result.ENDDAFLG}" == 'X' ? "Y" : "N", //결제종료인 경우 Y
	        "cancelYn" : $("#iCANFLG_after:checked").val() == "X" ? "Y" : "N", 
	        "zlcty" : ("${reqParam.ACTION}" == "APPLY") ? "10" : "${result.FLWTY}", //근무유형
	        "zlcod" : ("${reqParam.ACTION}" == "APPLY") ? "10" : "${result.TMDTY}",  //세부유형      
	        "ars_min" : "",  //근무시간(최소)
	        "ars_max" : "",  //근무시간(최대)
	        "wostd" : "",    //주간근무시간
	        "msgCode" : "${result.MSGCODE}",
	        "message" : "${result.MESSAGE}"
	}  
    console.log("comm param=>", param)
    
    fn_formDetailAjax("<c:url value='/ess/pa.selectFlexibleWorkFormDetail.do'/>", param);
    if("DETAIL" == param.ACTION){
        fn_commAttrDisabled_${param.changeFlag}()
    	$("#formCommDiv_"+param.changeFlag).find("input[type=checkbox]").prop("disabled",true);
    } else if("APPLY" == param.ACTION){
        fn_commAttrEnabled_${param.changeFlag}()
    } else if("UPDATE" == param.ACTION) {
    	if(param.changeFlag == "before"){
    		fn_commAttrDisabled_${param.changeFlag}();
    	}else if(param.changeFlag == "after"){
    		fn_commAttrEnabled_${param.changeFlag}();
    	}
    } else{
        fn_commAttrDisabled_${param.changeFlag}()
    }
    	
})

// 이용 가능
function fn_commAttrEnabled_${param.changeFlag}(){
	var formCommDiv = "#formCommDiv_"+param.changeFlag;
	
	$(formCommDiv).find(".calendar_wrap input[type=text]").prop("disabled", false);
	$(formCommDiv).find("select").prop("disabled", false);
//     $(formCommDiv).find("label").attr("disabled", false);
    $(formCommDiv).find(".calendar label").css("display", "");
}
// 이용 불가능
function fn_commAttrDisabled_${param.changeFlag}(){
	var formCommDiv = "#formCommDiv_"+param.changeFlag;
	
	$(formCommDiv).find(".calendar_wrap input[type=text]").prop("disabled", true);
	$(formCommDiv).find("select").prop("disabled", true);
//     $(formCommDiv).find("label").attr("disabled", true);
    $(formCommDiv).find(".calendar label").css("display", "none");
}

<c:if test ="${reqParam.ACTION eq 'APPLY' || (reqParam.ACTION eq 'UPDATE' && param.changeFlag eq 'after') || (reqParam.ACTION eq 'ENDAPPLY' && param.changeFlag eq 'after')}">

//근무유형 선택
var sFLWTY_prevVal = ""; // 근무유형 이전 선택값 
$("#sFLWTY_${param.changeFlag}").focus(function(){
    sFLWTY_prevVal = $(this).val();
}).change(function(event){
	if(param.cancelYn == 'N'){
		if(next == "N"){
			if(!confirm("입력된 값이 초기화됩니다. 변경하시겠습니까?")){
		        return $(this).val(sFLWTY_prevVal);
			}
	    }else if( next == "Y") {
	        alert("처리 중입니다. ");
	        return $(this).val(sFLWTY_prevVal);
	    }
        param.initYn = "Y";
	}else{
        param.initYn = "N";
	}
	
    var zlcty =  $(this).find("option:selected").val();
    param.zlcty = zlcty;
    param.content = $(this).find("option:selected").attr("content");
    
    //세부유형 option 재표시 
    var options = getSelectOptions("sTMDTY", param.changeFlag, zlcty, ""); 
    appendOptions("sTMDTY", param.changeFlag, options);
    
    if(zlcty == "20" || zlcty == "80"){
    	$("#sTMDTY_after").hide();
     	if(zlcty == "80"){
 	        $("#timeWeekNm_"+param.changeFlag).text("주간육아시간");
     	}else{
 	        $("#timeWeekNm_"+param.changeFlag).text("주간근무시간");
     	}
    	$("#tmdtyNm_"+param.changeFlag).hide()
    	param.zlcod = "";
        param.changeFlag = "after";
        param.cancelYn = $("#iCANFLG_after:checked").val() == "X" ? "Y" : "N";
        
        fn_formDetailAjax("<c:url value='/ess/pa.selectFlexibleWorkFormDetail.do'/>", param);
    }else {
        $("#timeWeekNm_"+param.changeFlag).text("주간근무시간")
    	$("#tmdtyNm_"+param.changeFlag).show()
    	$("#sTMDTY_after").show();
    }
    
    $("#formDetailDiv_after").empty()
    
})

//세부유형 선택
var sTMDTY_prevVal = ""; // 세부유형 이전 선택값 
$("#sTMDTY_${param.changeFlag}").focus(function(){
	console.log('test sTMDTY focus')
    sTMDTY_prevVal = $(this).val();
}).change(function(){
	console.log('test sTMDTY change: '+ $(this).val())
	if(param.cancelYn == 'N'){
		if(next == "N"){
            if(!confirm("입력된 값이 초기화됩니다. 변경하시겠습니까??")){
                return $(this).val(sTMDTY_prevVal);
            }
        }else if( next == "Y") {
            alert("처리 중입니다. ");
            return $(this).val(sTMDTY_prevVal);
        }
        param.initYn = "Y";
	}else{
        param.initYn = "N";
	}
	
    next = "Y";

    var zlcod = $(this).find("option:selected").val(); // 세부유형
    
    param.zlcod = zlcod;
    param.changeFlag = "after";
    param.cancelYn = $("#iCANFLG_after:checked").val() == "X" ? "Y" : "N";
    fn_formDetailAjax("<c:url value='/ess/pa.selectFlexibleWorkFormDetail.do'/>", param);
})
</c:if>
</script>


<div class="formCommDiv" id="formCommDiv_${param.changeFlag}">
	<table class="table_st01">
		<colgroup>
			<col width="150">    
			<col width="350">   
			<col width="100">   
			<col width="*">   
			<col width="100">  
			<col width="100">   
		</colgroup>
		<thead>
            <c:if test="${param.titleUseYn eq 'Y'}">
			    <tr>
			        <th colspan="6" style="text-align:left; background:gray; color:white;">
						<div class="title_top">
		                    <p class="tit_02" style="background:none; margin:0px;">${changeText}</p>
		                </div>
				    </th>
				</tr>
	        </c:if>   
	        <tr style="display:none">
		        <input type="hidden" class="vFLWNO" value= "${result.FLWNO}" /> 
		        <input type="hidden" class="vSEQNR" value= "${result.SEQNR}" /> 
		        <input type="hidden" class="vCANFLG" value= "${result.CANFLG}" /> 
		        <input type="hidden" class="vENDDAFLG" value= "${result.ENDDAFLG}" /> 
		        <input type="hidden" class="vWKWDY" value= "${result.WKWDY}" /> 
		        <input type="hidden" class="vWOSTD" value= "${result.WOSTD}" /> 
		        <input type="hidden" class="vFLWTY" value= "${result.FLWTY}" /> 
	            <input type="hidden" class="vTMDTY" value= "${result.TMDTY}" /> 
	            <input type="hidden" class="vBEGDA" value= "<fmt:formatDate pattern="yyyy.MM.dd" value="${result.BEGDA}"/>" /> 
                <input type="hidden" class="vENDDA" value= "<fmt:formatDate pattern="yyyy.MM.dd" value="${result.ENDDA}"/>" /> 
	            <input type="hidden" class="vZAT01" value= "${result.ZAT01}" /> 
	            <input type="hidden" class="vZAT02" value= "${result.ZAT02}" /> 
	            <input type="hidden" class="vZAT03" value= "${result.ZAT03}" /> 
	            <input type="hidden" class="vZAT04" value= "${result.ZAT04}" /> 
	            <input type="hidden" class="vZAT05" value= "${result.ZAT05}" /> 
	            <input type="hidden" class="vBEZ01C" value= "${result.BEZ01C}" /> 
	            <input type="hidden" class="vBEZ02C" value= "${result.BEZ02C}" /> 
	            <input type="hidden" class="vBEZ03C" value= "${result.BEZ03C}" /> 
	            <input type="hidden" class="vBEZ04C" value= "${result.BEZ04C}" /> 
	            <input type="hidden" class="vBEZ05C" value= "${result.BEZ05C}" /> 
	            <input type="hidden" class="vBEZ01M" value= "${result.BEZ01M}" /> 
	            <input type="hidden" class="vBEZ02M" value= "${result.BEZ02M}" /> 
	            <input type="hidden" class="vBEZ03M" value= "${result.BEZ03M}" /> 
	            <input type="hidden" class="vBEZ04M" value= "${result.BEZ04M}" /> 
	            <input type="hidden" class="vBEZ05M" value= "${result.BEZ05M}" /> 
	            <input type="hidden" class="vENZ01C" value= "${result.ENZ01C}" /> 
	            <input type="hidden" class="vENZ02C" value= "${result.ENZ02C}" /> 
	            <input type="hidden" class="vENZ03C" value= "${result.ENZ03C}" /> 
	            <input type="hidden" class="vENZ04C" value= "${result.ENZ04C}" /> 
	            <input type="hidden" class="vENZ05C" value= "${result.ENZ05C}" />
	            <input type="hidden" class="vENZ01M" value= "${result.ENZ01M}" /> 
	            <input type="hidden" class="vENZ02M" value= "${result.ENZ02M}" /> 
	            <input type="hidden" class="vENZ03M" value= "${result.ENZ03M}" /> 
	            <input type="hidden" class="vENZ04M" value= "${result.ENZ04M}" /> 
	            <input type="hidden" class="vENZ05M" value= "${result.ENZ05M}" /> 
                <input type="hidden" class="vARS01" value= "${result.ARS01}" /> 
                <input type="hidden" class="vARS02" value= "${result.ARS02}" /> 
                <input type="hidden" class="vARS03" value= "${result.ARS03}" /> 
                <input type="hidden" class="vARS04" value= "${result.ARS04}" /> 
                <input type="hidden" class="vARS05" value= "${result.ARS05}" />  
                <input type="hidden" class="vSUI01" value= "${result.SUI01}" /> 
                <input type="hidden" class="vSUI02" value= "${result.SUI02}" /> 
                <input type="hidden" class="vSUI03" value= "${result.SUI03}" /> 
                <input type="hidden" class="vSUI04" value= "${result.SUI04}" /> 
                <input type="hidden" class="vSUI05" value= "${result.SUI05}" />  
	            <input type="hidden" class="vBEZ01C_1" value= "${result.BEZ01C_1}" /> 
	            <input type="hidden" class="vBEZ02C_1" value= "${result.BEZ02C_1}" /> 
	            <input type="hidden" class="vBEZ03C_1" value= "${result.BEZ03C_1}" /> 
	            <input type="hidden" class="vBEZ04C_1" value= "${result.BEZ04C_1}" /> 
	            <input type="hidden" class="vBEZ05C_1" value= "${result.BEZ05C_1}" /> 
                <input type="hidden" class="vBEZ01M_1" value= "${result.BEZ01M_1}" /> 
                <input type="hidden" class="vBEZ02M_1" value= "${result.BEZ02M_1}" /> 
                <input type="hidden" class="vBEZ03M_1" value= "${result.BEZ03M_1}" /> 
                <input type="hidden" class="vBEZ04M_1" value= "${result.BEZ04M_1}" /> 
                <input type="hidden" class="vBEZ05M_1" value= "${result.BEZ05M_1}" /> 
                <input type="hidden" class="vENZ01C_1" value= "${result.ENZ01C_1}" /> 
                <input type="hidden" class="vENZ02C_1" value= "${result.ENZ02C_1}" /> 
                <input type="hidden" class="vENZ03C_1" value= "${result.ENZ03C_1}" /> 
                <input type="hidden" class="vENZ04C_1" value= "${result.ENZ04C_1}" /> 
                <input type="hidden" class="vENZ05C_1" value= "${result.ENZ05C_1}" />
                <input type="hidden" class="vENZ01M_1" value= "${result.ENZ01M_1}" /> 
                <input type="hidden" class="vENZ02M_1" value= "${result.ENZ02M_1}" /> 
                <input type="hidden" class="vENZ03M_1" value= "${result.ENZ03M_1}" /> 
                <input type="hidden" class="vENZ04M_1" value= "${result.ENZ04M_1}" /> 
                <input type="hidden" class="vENZ05M_1" value= "${result.ENZ05M_1}" />
                <input type="hidden" class="vARS01_1" value= "${result.ARS01_1}" /> 
                <input type="hidden" class="vARS02_1" value= "${result.ARS02_1}" /> 
                <input type="hidden" class="vARS03_1" value= "${result.ARS03_1}" /> 
                <input type="hidden" class="vARS04_1" value= "${result.ARS04_1}" /> 
                <input type="hidden" class="vARS05_1" value= "${result.ARS05_1}" />  
	            <input type="hidden" class="vSUI01" value= "${result.SUI01}" />  
	            <input type="hidden" class="vSUI02" value= "${result.SUI02}" />  
	            <input type="hidden" class="vSUI03" value= "${result.SUI03}" />  
	            <input type="hidden" class="vSUI04" value= "${result.SUI04}" />  
	            <input type="hidden" class="vSUI05" value= "${result.SUI05}" />  
	                        
	            <input type="hidden" class="vAPNOTE" value= "${result.APNOTE}" /> 
	            <input type="hidden" class="vFAMTY" value= "${result.FAMTY}" /> 
	            <input type="hidden" class="vFAMID" value= "${result.FAMID}" /> 
	            <input type="hidden" class="vWEEKNUM" value= "${result.WEEKNUM}" /> 
	            <input type="hidden" class="vWEEKSUM" value= "${result.WEEKSUM}" /> 
	            
	            <input type="hidden" class="vWKWDAY" value= "${result.WKWDAY}" /> 
	            <input type="hidden" class="vBEZHOR" value= "${result.BEZHOR}" /> 
	            <input type="hidden" class="vBEZMIN" value= "${result.BEZMIN}" /> 
	            <input type="hidden" class="vENZHOR" value= "${result.ENZHOR}" /> 
	            <input type="hidden" class="vENZMIN" value= "${result.ENZMIN}" /> 
	            <input type="hidden" class="vARSTIM" value= "${result.ARSTIM}" /> 
	        </tr>
	        <c:choose>
                <c:when test="${(reqParam.ACTION eq 'DETAIL' && param.changeFlag eq 'after' && result.ENDDAFLG eq 'X') || (reqParam.ACTION eq 'ENDAPPLY' && param.changeFlag eq 'after'  )}">
                <!-- 종료결재인 상세화면 , 종료결재할 떄 -->
                <tr style="display:none;">
                    <td>
                        <select name="sFAMTY_Temp" class="select sFAMTY_Temp"> <!-- 자녀선택 -->
                            <option value=""></option> 
                            <c:forEach var="item" items="${ITAB13}" varStatus="status">
                                <option value="${item.FAMSA}" objps="${item.OBJPS}"> ${item.FCNAM}</option>
                            </c:forEach> 
                        </select>
                    </td>
                </tr>
                </c:when>
                <c:otherwise>
                <tr>
					<th>신청번호</th>
					<td>
					    <c:set var="flwno" value="${reqParam.ACTION eq 'APPLY' ? '' : result.FLWNO}" />
		                <input type="text" class="vFLWNO" style="width:100px !important;" value= "${flwno}" disabled/> 
		                
					    <c:set var="seqnr" value="${reqParam.ACTION eq 'APPLY' ? '' : result.SEQNR}" />
		                <input type="text" class="vSEQNR" style="width: 50px !important; min-width:50px;" value= "${seqnr}" disabled/> 
		                
		                <c:if test="${result.CANFLG eq 'X' || (reqParam.ACTION eq 'UPDATE' && param.changeFlag eq 'after')}">
			                <label style="padding-top: 7px; float: right;" style="display:none;">
		                        <span style="margin-right: 5px; font-size:15px; font-weight:500;">취소</span>
		                        <input type="checkbox" id="iCANFLG_${param.changeFlag}" value="X" <c:if test="${result.CANFLG eq 'X'}">checked</c:if>/>
			                </label>
		                </c:if>
		            </td>
		            <th>근무유형</th>
					<td>
			            <div class="select_wrap">
	                        <c:set var="sFLWTY_NM" value="sFLWTY_${param.changeFlag}"/>			              
				            <select name="${sFLWTY_NM}" id="${sFLWTY_NM}" class="select sFLWTY_Form" style="min-width:300px;">
								<option value="">선택하세요</option> 
                                <c:set var="selected_FLWTY" value="${reqParam.ACTION eq 'APPLY' ? 10 : result.FLWTY}"/>
								<c:choose>
		                            <c:when test="${reqParam.ACTION eq 'DETAIL'}">
										<c:forEach var="item" items="${ITAB6}" varStatus="status">
										    <option value="${item.ZLCOD}" ${selected_FLWTY == item.ZLCOD ? "selected" : ""}>${item.ZLCOD}. ${item.ZLCODT}</option>
										</c:forEach>
		                            </c:when>
		                            <c:otherwise>
										<c:forEach var="item" items="${T_RESULT}" varStatus="status">
<%-- 		                                    <c:if test="${item.KEY_FIELD ne '20'}"> --%> <!-- 근무유형 20번 테스트 -->
										    <option value="${item.KEY_FIELD}" ${item.KEY_FIELD eq selected_FLWTY ? "selected" : ""}>${item.KEY_FIELD}. ${item.VALUE_FIELD}</option>
<%-- 		                                    </c:if> --%>
										</c:forEach>
		                            </c:otherwise>
								</c:choose>
				            </select>
			            </div>
			        </td>
					<th>주간근무일수</th>
					<td class="workDayWeek" style="text-align:center;">
		                <input type="text" style="min-width:50px;" value="${result.WKWDY}" disabled/> 
		            </td>
		        </tr>
		        <tr>
				    <th>유연근무제 기간</th>
				    <td>
		                <ul class="calendar_wrap">
		                    <li class="calendar">
	                            <c:set var="BEGDA_NM" value ="oBEGDA_${param.changeFlag}"/>
	                            <fmt:formatDate var="oBEGDA_Comm" value="${result.BEGDA}" pattern="yyyy.MM.dd" />
	                            <input type="text" name="${BEGDA_NM}" id="${BEGDA_NM}" value="${oBEGDA_Comm}"/><label for="${BEGDA_NM}" onclick="$.showCal2('${BEGDA_NM}')" style="vertical-align:top;">달력</label>
		                    </li>
		                    <li class="wave">~</li>
							<li class="calendar">
	                            <c:set var="ENDDA_NM" value ="oENDDA_${param.changeFlag}"/>
	                             <fmt:formatDate var="oENDDA_Comm" value="${result.ENDDA}" pattern="yyyy.MM.dd" />
	                             <input type="text" name="${ENDDA_NM}" id="${ENDDA_NM}" value="${oENDDA_Comm}"/><label for="${ENDDA_NM}" onclick="$.showCal2('${ENDDA_NM}')" style="vertical-align:top;">달력</label>
		                    </li>
		                </ul>
		            </td>
		            <th>
                        <span id="tmdtyNm_${param.changeFlag}" <c:if test="${selected_FLWTY eq '20' || selected_FLWTY eq '80'}">style='display:none;'</c:if> >세부유형</span>
		            </th>
		            <td>
		                <div class="select_wrap">
		                    <c:set var="sTMDTY_NM" value ="sTMDTY_${param.changeFlag}"/>
							<select name="${sTMDTY_NM}" id="${sTMDTY_NM}" class="select sTMDTY_Form" style="min-width:300px; <c:if test="${selected_FLWTY eq '20' || selected_FLWTY eq '80'}">display:none;</c:if>" >
								<option value="">선택하세요</option> 
								<c:forEach var="item" items="${ITAB14}" varStatus="status">
							        <c:set var="selected_TMDTY" value="${reqParam.ACTION eq 'APPLY' ? '10' : result.TMDTY}"/>
									<c:if test="${item.ZLCTY == selected_FLWTY}">
									   <option value="${item.ZLCOD}" ${selected_TMDTY == item.ZLCOD ? "selected" : ""}
                                               zlcty="${item.ZLCTY}" zlcod="${item.ZLCOD}" 
									           min="${item.MIN}" max="${item.MAX}"  wostd="${item.WOSTD}" >${item.ZLCOD}. ${item.ZLCODT}</option>
									</c:if>
								</c:forEach>
	                        </select>
	                           
	                        <!-- 맵핑용 select -->
							<select name="sTMDTY_Temp" class="select sTMDTY_Temp" > <!-- 세부유형 -->
                                <option value="">선택하세요</option> 
								<c:forEach var="item" items="${ITAB14}" varStatus="status">
								    <option value="${item.ZLCOD}" zlcty="${item.ZLCTY}" zlcod="${item.ZLCOD}" 
								            min="${item.MIN}" max="${item.MAX}"  wostd="${item.WOSTD}" >${item.ZLCOD}. ${item.ZLCODT}</option>
								</c:forEach>
			                </select>
			                
			                <select name="sWKWDAY_Temp" class="select sWKWDAY_Temp"> <!-- 시간선택제 근무일수  -->
                                <option value=""></option> 
                                <c:forEach var="item" items="${ITAB9}" varStatus="status">
                                    <option value="${item.KEY}" zlcty="${item.ZLCTY}" zlcod="${item.ZLCOD}"> ${item.TEXT}</option>
                                </c:forEach> 
                            </select>
                            
			                <select name="sFAMTY_Temp" class="select sFAMTY_Temp"> <!-- 자녀선택 -->
                                <option value=""></option> 
                                <c:forEach var="item" items="${ITAB13}" varStatus="status">
                                    <option value="${item.FAMSA}" objps="${item.OBJPS}"> ${item.FCNAM}</option>
                                </c:forEach> 
                            </select>
                            
			                <select name="sZAT_Temp" class="select sZAT_Temp"> <!-- 근무구분 -->
                                <option value="">선택하세요</option> 
                                <c:forEach var="item" items="${ITAB8}" varStatus="status">
                                    <option value="${item.KEY}" zlcty="${item.ZLCTY}" zlcod="${item.ZLCOD}">${item.KEY}. ${item.TEXT}</option>
                                </c:forEach> 
                            </select>
	                           
			                <select name="sBEZ_C_Temp" class="select sHM sBEZ_C_Temp"> <!-- 시작 시 -->
                                <option value=""></option> 
	                            <c:forEach var="item" items="${ITAB10}" varStatus="status">
	                                <option value="${item.KEY}" zlcty="${item.ZLCTY}" zlcod="${item.ZLCOD}">${item.TEXT}</option>
	                            </c:forEach>
	                        </select>
			                
			                <select name="sBEZ_M_Temp" class="select sHM sBEZ_M_Temp"> <!-- 시작 분 -->
                                <option value=""></option> 
	                            <c:forEach var="item" items="${ITAB12}" varStatus="status">
	                                <option value="${item.KEY}" zlcty="${item.ZLCTY}" zlcod="${item.ZLCOD}">${item.TEXT}</option>
	                            </c:forEach>
	                        </select>
	                           
	                        <select name="sENZ_C_Temp" class="select sHM sENZ_C_Temp"> <!-- 종료 시 -->
                                <option value=""></option> 
	                            <c:forEach var="item" items="${ITAB11}" varStatus="status">
	                                <option value="${item.KEY}" zlcty="${item.ZLCTY}" zlcod="${item.ZLCOD}">${item.TEXT}</option>
	                            </c:forEach>
	                        </select>
	               
	                        <select name="sENZ_M_Temp" class="select sHM sENZ_M_Temp"> <!-- 종료 분 -->
                                <option value=""></option> 
	                            <c:forEach var="item" items="${ITAB12}" varStatus="status">
	                                <option value="${item.KEY}" zlcty="${item.ZLCTY}" zlcod="${item.ZLCOD}">${item.TEXT}</option>
	                            </c:forEach>
	                        </select>			                
		                </div>
		            </td>
				    <th class="timeWeekNm" id="timeWeekNm_${param.changeFlag}">${result.FLWTY eq '80' ? '주간육아시간' : '주간근무시간'}</th>
				    <td class="workTimeWeek" style="text-align:center;">
		                <input type="text" style="min-width:50px;" value= "${result.WOSTD }" disabled/> 
		            </td>
		        </tr>
                </c:otherwise>
	        </c:choose>
	    </thead>
	</table>
</div>
<div class="formDetailDiv" id ="formDetailDiv_${param.changeFlag}"></div>       
