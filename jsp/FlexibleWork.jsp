<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 
AS-IS
메뉴경로    : ESS>근태>유연근무제
화면명 : 신청관리
화면개요    : 유연근무 목록(내역), 유연근무 상세화면 
--%>
<jsp:include page="../../include/ess_header.jsp"/><!-- 헤더 -->
<c:set var="now" value="<%=new java.util.Date()%>"/>
<c:set var="today"><fmt:formatDate value="${now}" pattern="yyyyMMdd"/></c:set>

<style>
    .loading {
            align-items : center;
            justify-content : center;
            text-align:center;
            display:table;
            height: 100%;
            width : 100%;
            z-index: 99998;
            background-color: white;
            position : absolute;
            opacity : 0.8; /*2022.02.25*/
    }
    .loader {
        border : 16px solid #f3f3f3;
        border-radius : 50%;
        border-top : 16px solid blue;
        border-right : 16px solid green;
        border-bottom : 16px solid red;
        border-left : 16px solid pink;
        width : 50px;
        height : 50px;
        display:table-cell;
        z-index: 99999;
        vertical-align: middle;
        text-align:center;
        -webkit-animation: spin 2s linear infinite;
        animation :  spin 2s linear infinite;
    }
    @-webkit-keyframes spin {
        0% { -webkit-transform : rotate(0deg); }
        100% { -webkit-transform : rotate(360deg);}
    }
    @keyframes spin {
         0% {  transform : rotate(0deg); }
        100% { transform : rotate(360deg);}
    } 
    .textss {
        font-size : 13.5px;
        letter-spacing : 0.2px;
        letter-height : 0.5px;
        font-family :  ngttf;
        padding: 0 0 0 0;
        margin: 0 0 0 0; 
        word-break:break-all
    } 
    .stop-dragging{
        -ms-user-select : none;
        -moz-user-select : -moz-none;
        -khtml-user-select : none;
        -webkit-user-select : none;
        user-select : none;
    }
    .selectRow {background:#f5f5f5;}
    .tableFixHead{overflow-y:auto; max-height:250px;}
    .tableFixHead thead th{position:sticky; top:-1px;}
    table.table_st01 th, table.table_st01 td {padding:3px 10px !important;} 
    .calendar{margin-bottom:0px !important;}
    .select{min-width:100px; padding-right: 0px; }
    
    .text-danger{color:#ff0000}
</style>

<script type="text/javascript">
var next = "N" ; // 비동기(ajax) 플래그 변수 (Y:호출중, N:종료)

// var CLIP_REPORT_URL = "${CLIP_REPORT_URL}";
// var REX_USERSERVICE = "${REX_USERSERVICE}";

$(document).ready(function() {
    if ( $("#aList tbody tr").length > 5 ) {
        $("#aListDiv").addClass("tableFixHead")
        if(isIE()){ //IE인 경우 thead 고정시키기
            // Fix table head
            function tableFixedHead(ths){
                var sT = this.scrollTop;
                [].forEach.call(ths, function(th) {
                    th.style.transform = "translateY("+ sT + "px)";
                });
            }
            [].forEach.call(document.querySelectorAll(".tableFixHead"), function (el){
                var ths = el.querySelectorAll("thead th"); 
                el.addEventListener("scroll", tableFixedHead.bind(el, ths));
            })
        }
    }
    $(".btnMark").hide();
    $(".loading").hide(); 
    
    // 검색
    $("#btnSearch").on("click", function(e) {
        e.preventDefault();
        fn_search();
    });
    
    // 신청서 row 클릭 - 상세화면 조회
    $("#aList tbody tr").off().on("click", function(e, idx) {
        e.preventDefault();
        if( next == "Y") {
             alert("처리 중입니다. ");
             return;
        }
        next = "Y";
        
        $("#aList tr").removeClass("selectRow")
        $(this).addClass("selectRow");
        
        document.searchForm.iFLWNO.value= $(this).find("input[name='oFLWNO']").val()
        document.searchForm.iSEQNR.value= $(this).find("input[name='oSEQNR']").val()
        document.searchForm.iPERNR.value= $(this).find("input[name='oPERNR']").val()
        document.searchForm.iBEGDA.value= $(this).find("input[name='oBEGDA']").val()
        document.searchForm.iENDDA.value= $(this).find("input[name='oENDDA']").val()
        document.searchForm.iRGUBN.value= $(this).find("input[name='oRGUBN']").val()
        document.searchForm.iDATUM.value= $(this).find("input[name='oDATUM']").val()
        document.searchForm.iSTATUS.value= $(this).find("input[name='oSTATUS']").val()
        document.searchForm.iFLWTY.value= $(this).find("input[name='oFLWTY']").val()
        document.searchForm.iTMDTY.value= $(this).find("input[name='oTMDTY']").val()
        document.searchForm.iZWFKEY.value= $(this).find("input[name='oZWFKEY']").val()
        document.searchForm.iCANFLG.value= $(this).find("input[name='oCANFLG']").val()
        document.searchForm.iACTION.value= "DETAIL";
        
        var status = $(this).find("input[name='oSTATUS']").val()
        fn_btnChk(status)
        
        fn_detailAjax("<c:url value='/ess/pa.selectFlexibleWorkForm.do'/>", "#searchForm", "#aListDetailDiv");
    });
});

function isIE(){
    return navigator.userAgent.indexOf('MSIE') > -1 || navigator.appVersion.indexOf('Trident') >-1
}

//신청서 검색
function fn_search(){
    if( next == "Y") {
        alert("처리 중입니다. ");
        return;
    }
    next = "Y";
    
    // 시작일, 종료일 (날짜 yyyymmdd 형식)
    document.searchForm.iBEGDA.value= $("#oBEGDA").val().replace(/\./gi, "");
    document.searchForm.iENDDA.value= $("#oENDDA").val().replace(/\./gi, "");
    document.searchForm.iFLWTY.value= $("#sFLWTY option:selected").val();
    document.searchForm.iSTATUS.value= $("#sSTATUS option:selected").val();
    document.searchForm.iACTION.value= "SEARCH";
    
    $("#searchForm").attr("action","<c:url value='/ess/pa.selectFlexibleWork.do'/>").attr("target", "").submit();
}

// 신청서 상세 조회 
function fn_detailAjax(urlVal, form, div){
    $(div).empty();

    $.ajax({
        url: urlVal,
        type: "post",
        dataType: "html",
        data : $(form).serialize() ,   
//      async: false,
        success:function(result) {
            $(div).append(result);
        },
        error : function(request, status, error) {
        	console.log(request)
        	console.log(status)
        	console.log(error)
            cfAlertMsg("오류가 발생하였습니다.");
        },
        complete : function(){
            next = "N";
        }
    }).always(function(){
        next = "N";
    })
}

function fn_btnChk(status){
    $(".btnMark").hide();  
    
    if(status == 'S'){//기안이면
        $("#btnNew").show();    //신규신청버튼  표시
        $("#btnCancel").show();   // 결제회수버튼 표시
    }else if(status == 'A'){//결재이면
    	var iRGUBN = $("#iRGUBN").val()    //구분
    	var iCANFLG = $("#iCANFLG").val()  //결재상태
    	
        $("#btnNew").show();    //신규신청버튼  표시
        if(iRGUBN == 'P'){ //ESS처리
	        if(iCANFLG != 'X'){ //취소상태 아니면
		        $("#btnUpdate").show(); // 결재변경 표시
		        $("#btnEnd").show();    //종료신청 표시
	        }
        }else if(iRGUBN == ''){ // (R/3)
	        if(iCANFLG == 'X'){ //취소상태이면
	        }else{
		        $("#btnUpdate").show(); // 결재변경 표시
		        $("#btnEnd").show();    //종료버튼 표시
	        }
        }
    }else if(status == 'R'){ //반려(R/3)
        $("#btnNew").show();    //신규신청버튼  표시
        $("#btnDelete").show();    //삭제버튼 표시
    }else if(status == 'APPLY'){
        $("#btnNew").hide();    //신규신청버튼  표시
        $("#btnEsc").show();    //닫기버튼 표시
    
        $('#aList tr[class=selectRow]').removeClass('selectRow')
    }else if(status == 'ESC'){
        $("#btnNew").show();    //신규신청버튼  표시
        $("#btnEsc").hide();    //닫기버튼 표시
    }
}

// 버튼 기능 
function fn_process(type){
    if( next == "Y") {
        alert("처리 중입니다. ");
        return;
    }
    next = "Y";
    
    if(type == "APPLY"){    // 신규신청 
        document.searchForm.iACTION.value= type;
        document.searchForm.iFLWTY.value= "10";
        document.searchForm.iTMDTY.value= "10";
//         document.searchForm.iBEGDA.value= "";
//         document.searchForm.iENDDA.value= "";
        fn_btnChk(type)
        fn_detailAjax("<c:url value='/ess/pa.selectFlexibleWorkForm.do'/>", "#searchForm", "#aListDetailDiv");
    }else if(type == "ESC"){
    	$("#aListDetailDiv").empty();
        fn_btnChk(type)
        next = "N";
    }else if(type == "UPDATE" || type == "ENDAPPLY"){ // 결재변경, 종료신청
        document.searchForm.iACTION.value= type;
        document.searchForm.iBEGDA.value= "";
        document.searchForm.iENDDA.value= "";
        fn_detailAjax("<c:url value='/ess/pa.selectFlexibleWorkForm.do'/>", "#searchForm", "#aListDetailDiv");
    }else if(type == "REQCANCEL" ){ // 결재회수
        document.searchForm.iACTION.value= type;
        fn_save(type) // ApplicationDetail.jsp에서 호출
    }else if(type == "DELETE" ){
        if(confirm("삭제하시겠습니까?"))
    	fn_save(type) // ApplicationDetail.jsp에서 호출
    }else{
        cfAlertMsg("오류가 발생하였습니다.");
    }
    
}

function fillZero(width, str){
	if(str == ""){
		return new Array(width+1).join('0')
	}
    // 남는 길이만큼 0으로 채움
    return str.length >= width ? str : new Array(width-str.length+1).join('0')+str; 
}

</script>

<body>
<!-- 로딩 -->
<div class="loading">
    <div style="text-align: center; vertical-align: middle; display: table-cell; align-items: center; align-self: center;">
        <div style="display: inline">
            <div class="loader"></div>
        </div>
    </div>
</div> 


<!-- wrap -->
<div class="wrap" style="max-height:1500px; overflow-y:auto;">
    <form name="searchForm" id="searchForm" method="post">
        <input type="hidden" name="iACTION" id="iACTION" value="${reqParam.ACTION}"/> <!-- ajax템플릿(SEARCH:검색, DETAIL:상세조회, .... )  -->                         
        <input type="hidden" name="iBEGDA" id="iBEGDA" value="${reqParam.I_BEGDA}"/>               <!-- 시작일 -->
        <input type="hidden" name="iENDDA" id="iENDDA" value="${reqParam.I_ENDDA}"/>               <!-- 종료일 -->
        <input type="hidden" name="iFLWNO" id="iFLWNO" value="${reqParam.I_FLWNO}"/>               <!-- 유연근무제 관리 번호-->
        <input type="hidden" name="iSEQNR" id="iSEQNR" value="${reqParam.I_SEQNR}"/>               <!-- 유연근무제 관리 번호 SEQNO -->
        <input type="hidden" name="iPERNR" id="iPERNR" value="${reqParam.I_PERNR}"/>              <!-- 사번(신청자) -->                
        <input type="hidden" name="iRGUBN" id="iRGUBN" value="${reqParam.I_RGUBN}"/>             <!-- 처리구분 -->
        <input type="hidden" name="iDATUM" id="iDATUM" value="${reqParam.I_DATUM}"/>           <!-- 조회기준일자 -->
        <input type="hidden" name="iSTATUS" id="iSTATUS" value="${reqParam.I_STATUS}"/>           <!-- 결재여부 -->
        <input type="hidden" name="iFLWTY" id="iFLWTY" value="${reqParam.I_FLWTY}"/>              <!-- 근무유형 -->   
        <input type="hidden" name="iTMDTY" id="iTMDTY" value="${reqParam.I_TMDTY}"/>              <!-- 세뷰유형 -->                
        <input type="hidden" name="iZWFKEY" id="iZWFKEY" value=""/>              <!-- 오브젝트키-->                
        <input type="hidden" name="iCANFLG" id="iCANFLG" value=""/>              <!-- 취소여부-->                
    </form>

    <div style="width:100%;height:30px;">
    </div> <!-- //header -->
    <div class="container">
        <div class="sub_container">
            <div class="content">
                <div class="title_top">
                    <p class="tit_02">신청내역</p>
                </div>
                <table summary="유연근무제 신청목록" class="table_st01">
<%--                     <caption>신청내역</caption> --%>
                    <colgroup>
                        <col width="80">    <!-- 기간 -->
                        <col width="300">   <!-- 기간 select -->
                        <col width="100">   <!-- 근무유형 -->
                        <col width="250">   <!-- 근우유형 select-->
                        <col width="100">   <!-- 결재상태 -->
                        <col width="150">   <!-- 결재상태 select -->
                        <col width="*">   <!-- 검색btn -->
                    </colgroup>
                    <tbody>
                        <tr>
                            <th>기간</th>
                            <td>
                                <ul class="calendar_wrap">
                                    <li class="calendar">
                                        <fmt:parseDate value="${reqParam.I_BEGDA}" pattern="yyyyMMdd" var="oBEGDA" />
                                        <fmt:formatDate var="oBEGDA_FMT" value="${oBEGDA}" pattern="yyyy.MM.dd" />
                                        <input type="text" name="oBEGDA" id="oBEGDA" value="${oBEGDA_FMT}"/><label for="oBEGDA" onclick="$.showCal2('oBEGDA')" style="vertical-align:top;">달력</label>
                                    </li>
                                    <li class="wave">~</li>
                                    <li class="calendar">
                                        <fmt:parseDate value="${reqParam.I_ENDDA}" pattern="yyyyMMdd" var="oENDDA" />
                                        <fmt:formatDate var="oENDDA_FMT" value="${oENDDA}" pattern="yyyy.MM.dd" />
                                        <input type="text" name="oENDDA" id="oENDDA" value="${oENDDA_FMT} "/><label for="oENDDA" onclick="$.showCal2('oENDDA')" style="vertical-align:top;">달력</label>
                                    </li>
                                </ul>
                            </td>
                            <th>근무유형</th>
                            <td>
                                <div class="select_wrap">
                                    <select name="sFLWTY" id="sFLWTY" class="select" style="min-width:200px;">
                                        <option value="">선택하세요</option> 
                                        <c:forEach var="item" items="${T_RESULT}" varStatus="status">
                                            <option value="${item.KEY_FIELD}" ${reqParam.I_FLWTY == item.KEY_FIELD ? "selected" : ""}>${item.KEY_FIELD}. ${item.VALUE_FIELD}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </td>
                            <th>결재상태</th>
                            <td>
                                <div class="select_wrap">
                                    <select name="sSTATUS" id="sSTATUS" class="select" >
                                        <option value="">선택하세요</option> 
                                        <option value="A" ${reqParam.I_STATUS == "A" ? "selected" : ""}>결재</option> 
                                        <option value="R" ${reqParam.I_STATUS == "R" ? "selected" : ""}>반려</option> 
                                        <option value="P" ${reqParam.I_STATUS == "P" ? "selected" : ""}>결재 중</option> 
                                        <option value="S" ${reqParam.I_STATUS == "S" ? "selected" : ""}>기안</option> 
                                        <option value="I" ${reqParam.I_STATUS == "I" ? "selected" : ""}>저장</option> 
<%--                                         <c:forEach var="item" items="${T_DROPDOWNLIST}" varStatus="status"> --%>
<%--                                             <c:set var="sZAPDAT"><fmt:formatDate value="${item.ZAPDAT}" pattern="yyyyMMdd"/></c:set> --%>
<%--                                             <c:if test="${sZAPDAT <= today}"> --%>
<%--                                                 <option value="${item.ZAPNO}" ${reqParam.I_ZAPNO == item.ZAPNO ? "selected" : ""}>${item.ZAPNOTX}</option> --%>
<%--                                             </c:if>  --%>
<%--                                         </c:forEach> --%>
                                    </select>
                                </div>
                            </td>
                            <td>
                                <div class="btn_right">
                                    <a href="javascript:void(0);" class="btn btn_1" id="btnSearch" style="width:80px">검색</a>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <div id="aListArticle" class="con_article" > <!-- //article -->
                    <div id="aListDiv" > <!-- 61 / 41 -->
                        <table summary="신청서 목록" class="list_st table_st01" id="aList" >
                            <caption>신청서목록</caption>
                            <colgroup>
                                <col width="100">   <!-- 신청일 -->
                                <col width="100">   <!-- 신청구분 -->
                                <col width="100">   <!-- 시작일 -->
                                <col width="100">   <!-- 종료일 -->
                                <col width="100">   <!-- 변경전 시작일 -->
                                <col width="100"> <!-- 변경전 종료일 -->
                                <col width="250"> <!-- 근무유형 -->
                                <col width="*"> <!-- 세부유형 -->
                                <col width="100"> <!-- 구분 -->
                                <col width="100"> <!-- 결재상태 -->
                            </colgroup>
                            <thead >
                                <tr>
                                    <th class="fixedHeader">신청일</th>
                                    <th class="fixedHeader">신청구분</th>
                                    <th class="fixedHeader">시작일</th>
                                    <th class="fixedHeader">종료일</th>
                                    <th class="fixedHeader">변경전 시작일</th>
                                    <th class="fixedHeader">변경전 종료일</th>
                                    <th class="fixedHeader">근무유형</th>    
                                    <th class="fixedHeader">세부유형</th>    
                                    <th class="fixedHeader">구분</th>    
                                    <th class="fixedHeader">결재상태</th>    
                                </tr>
                            </thead>
                            <tbody>
	                            <c:choose>
	                                <c:when test="${!empty ITAB1}">
	<%--                                     <c:forEach var="item" items="${T_HEADER}" varStatus="status" begin="0" end ="1" step="1"> --%>
	                                    <c:forEach var="item" items="${ITAB1}" varStatus="status" >
	<%--                                     <fmt:formatDate pattern="yyyy.MM.dd" value="${item.APPDT}"/> --%>
	                                        <tr>
	                                            <td><fmt:formatDate pattern="yyyy.MM.dd" value="${item.ERDAT}"/><!-- 신청일 -->
	                                                <input type="hidden" name="oFLWNO" value="${item.FLWNO}" />    <!-- 유연근무제 코드 -->
	                                                <input type="hidden" name="oSEQNR" value="${item.SEQNR}" />     <!-- 유연근무제 코드(순번) -->
	                                                <input type="hidden" name="oPERNR" value="${item.PERNR}" />     <!-- 사번(신청자) -->
	                                                <input type="hidden" name="oBEGDA" value="<fmt:formatDate pattern="yyyyMMdd" value="${item.BEGDA}"/>" />  <!-- 시작일 -->
	                                                <input type="hidden" name="oENDDA" value="<fmt:formatDate pattern="yyyyMMdd" value="${item.ENDDA}"/>" />  <!-- 종료일-->
	                                                <input type="hidden" name="oRGUBN" value="${item.RGUBN}" /> <!-- 구분-->
	                                                <input type="hidden" name="oDATUM" value="${item.DATUM}" /> <!-- 조회기준일자-->
	                                                <input type="hidden" name="oSTATUS" value="${item.STATUS}" /> <!-- 결재여부-->
	                                                <input type="hidden" name="oFLWTY" value="${item.FLWTY}" />    <!-- 근무유형 -->
	                                                <input type="hidden" name="oTMDTY" value="${item.TMDTY}" />    <!-- 세부유형 -->
	                                                <input type="hidden" name="oZWFKEY" value="${item.ZWFKEY}" />    <!--오브젝트키 -->
	                                                <input type="hidden" name="oCANFLG" value="${item.CANFLG}" />    <!--취소여부-->
	                                            <td>${item.STATTEXT}</td><!-- 신청구분 -->
	                                            <td><fmt:formatDate pattern="yyyy.MM.dd" value="${item.BEGDA}"/></td><!-- 시작일 -->
	                                            <td><fmt:formatDate pattern="yyyy.MM.dd" value="${item.ENDDA}"/></td><!-- 종료일 -->
	                                            <td><fmt:formatDate pattern="yyyy.MM.dd" value="${item.ORG_BEGDA}"/></td><!--변경전  시작일 -->
	                                            <td><fmt:formatDate pattern="yyyy.MM.dd" value="${item.ORG_ENDDA}"/></td><!--변경전 종료일 -->
	                                            <td>${item.FLWTYTX}</td><!-- 근무유형 -->
	                                            <td>${item.TMDTYTX}</td><!-- 세부유형 -->
	                                            <td>${item.RGUBNTX}</td><!-- 구분 -->
	                                            <td>${item.STATUST}</td><!-- 결재상태 -->
	                                        </tr>
	                                    </c:forEach>   
	                                </c:when>
	                                <c:otherwise>
	                                    <tr>
	                                        <td class="C" colspan="10"><spring:message code="info.nodata.msg" /></td>
	                                    </tr>
	                                </c:otherwise>
	                            </c:choose>
                            
                            </tbody>
                        </table>    
                    </div>
                </div>
                <div class="btn_wrap">
                    <div class="btn_right">
                        <a href="javascript:fn_process('APPLY');" class="btn btn_1" id="btnNew">신규신청</a>
                        <a href="javascript:fn_process('ESC');" class="btn btn_1 btnMark" id="btnEsc">닫기</a>
                        <a href="javascript:fn_process('UPDATE');" class="btn btn_1 btnMark" id="btnUpdate" >결재변경</a>
                        <a href="javascript:fn_process('DELETE');" class="btn btn_1 btnMark" id="btnDelete" >삭제</a>
                        <a href="javascript:fn_process('REQCANCEL');" class="btn btn_1 btnMark" id="btnCancel" >결재회수</a>
                        <a href="javascript:fn_process('ENDAPPLY');" class="btn btn_1 btnMark" id="btnEnd" >종료신청</a>
                    </div>
                </div> <!-- //btn_wrap -->
                
                <div class="con_article"> <!-- //article -->
                    <div id="aListDetailDiv"> <!-- 61 / 41 -->
                    </div>
                </div>
            </div><!-- //content -->                
        </div><!-- //sub_container -->   
        
    </div><!-- //container -->
    
    <div class="footer">
    </div>
    <!-- //bottom -->
</div><!-- //wrap -->
    
<form method="post" id="rexForm" name="rexForm" target="_blank">
    <input type="hidden" id="rex_rptname" name="rex_rptname" />
    <input type="hidden" id="rex_userservice" name="rex_userservice" />
    <input type="hidden" id="I_ZAPNO" name="I_ZAPNO" value=""/>
    <input type="hidden" id="I_ZAPDAT" name="I_ZAPDAT" value=""/>
    <input type="hidden" id="I_PERNR" name="I_PERNR" value=""/>
    <input type="hidden" id="I_ZAPPNUM" name="I_ZAPPNUM" value=""/>
    <input type="hidden" id="I_SEQNR" name="I_SEQNR" value=""/>
</form>
    
<%-- 결재 script include --%>
<jsp:include page="/WEB-INF/jsp/include/ess_approval_script.jsp"/>  
<%-- 결재 script include --%>     
<jsp:include page="../../include/ess_footer.jsp"/>  <!-- //body -->