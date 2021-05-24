<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>JobKorea</title>
<jsp:include page="/WEB-INF/view/common/common_include.jsp"></jsp:include>
<script type="text/javascript">
  // 그룹코드 페이징 설정
  var pageSizePcsOrderingOrder = 10;
  var pageBlockSizePcsOrderingOrder = 5;

  $(document).ready(function() {
    // 발주 지시서 조회
    fListPcsOrderingOrder();

    // 버튼 이벤트 등록
    fRegisterButtonClickEvent();
  });

  /** 버튼 이벤트 등록 */
  function fRegisterButtonClickEvent() {
    $('a[name=btn]').click(function(e) {
      e.preventDefault();

      var btnId = $(this).attr('id');

      switch (btnId) {
      case 'btnClosePurchBtn':
        gfCloseModal();
        break;
      case 'btnSubmitPurchBtn':
        fsend();
        break;        
      }
    });
  }

  /** 발주버튼 클릭 시 모달 실행 */
  function fPopModalPcsOrderingOrder(purch_list_no, supply_nm, prod_nm, m_ct_cd, purch_qty, purchase_price, desired_delivery_date, warehouse_nm, purch_mng_id, order_cd, supply_cd, scm_id) {
 
    // 신규 저장
    if (purch_list_no == null || purch_list_no == "") {
    } else {
      // 발주서 버튼 클릭 시 화면 출력
      fSelectPurchBtn(purch_list_no, supply_nm, prod_nm, m_ct_cd, purch_qty, purchase_price, desired_delivery_date, warehouse_nm, purch_mng_id, order_cd, supply_cd, scm_id);
    }
  }

  /** 제품 클릭 시 모달실행 */
  function fPopModalPcsOrderingOrder2(purch_list_no, supply_nm, prod_nm, m_ct_cd, purch_qty, purchase_price, desired_delivery_date, warehouse_nm, purch_mng_id, order_cd, supply_cd, scm_id) {
    
    // 신규 저장
    if (purch_list_no == null || purch_list_no == "") {
    } else {
      // 발주서 버튼 클릭 시 화면 출력
      fSelectPurchBtn(purch_list_no, supply_nm, prod_nm, m_ct_cd, purch_qty, purchase_price, desired_delivery_date, warehouse_nm, purch_mng_id, order_cd, supply_cd, scm_id);
    }
  }
  
  /** 발주지시서 목록 조회 */
  function fListPcsOrderingOrder(currentPage) {
    currentPage = currentPage || 1;

    console.log("currentPage : " + currentPage);

    var param = {
      currentPage : currentPage,
      pageSize : pageSizePcsOrderingOrder
    }
    
    var resultCallback = function(data) {
      flistPcsOrderingOrder(data, currentPage);
    };
    //Ajax실행 방식
    //callAjax("Url",type,return,async or sync방식,넘겨준거,값,Callback함수 이름)
    callAjax("/pcs/listPcsOrderingOrder.do", "post", "text", true, param, resultCallback);
  }

  /** 발주지시서 콜백 함수 */
  function flistPcsOrderingOrder(data, currentPage) {

    //alert(data);
    /* console.log(data); */

    // 기존 목록 삭제
    $("#listPcsOrderingOrder").empty();

    // 신규 목록 생성
    $("#listPcsOrderingOrder").append(data);

    // 총 개수 추출
    var totalCount = $("#totalCount").val();
    
    // 페이지 네비게이션 생성
    var paginationHtml = getPaginationHtml(currentPage, totalCount, pageSizePcsOrderingOrder, pageBlockSizePcsOrderingOrder, 'fListPcsOrderingOrder');
    console.log("paginationHtml : " + paginationHtml);
    //alert(paginationHtml);
    $("#pcsOrderingOrderPagination").empty().append(paginationHtml);

    // 현재 페이지 설정
    //$("#currentPage").val(currentPage);
  }

  /** 시간 변환 함수 
                출처 : https://stackoverflow.com/questions/23593052/format-javascript-date-as-yyyy-mm-dd
  */
  function formatDate(date) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) 
        month = '0' + month;
    if (day.length < 2) 
        day = '0' + day;

    return [year, month, day].join('-');
  }
  
  /** 발주서 화면 띄우기 */ 
  function fSelectPurchBtn(purch_list_no, supply_nm, prod_nm, m_ct_cd, purch_qty, purchase_price, desired_delivery_date, warehouse_nm, purch_mng_id, order_cd, supply_cd, scm_id) {
    $("#purchListNo").text(purch_list_no);
    $("#supplyNm").text(supply_nm);
    $("#prodNm").text(prod_nm);
    $("#mCtCd").text(m_ct_cd);
    $("#purchQty").text(purch_qty);
    $("#purchasePrice").text(purchase_price);
    // 날짜 타입 변환
    var date1 = desired_delivery_date.substr(0, 10);
    var date2 = desired_delivery_date.substr(24, 29);
    desired_delivery_date = date1 + ',' + date2;
    $("#desiredDeliveryDate").val(formatDate(desired_delivery_date));
    
    $("#warehouseNm").text(warehouse_nm);
    $("#purchMngId").val(purch_mng_id);
    
    gfModalPop("#layer1");
    
    console.log('purchMngId :' + purch_mng_id);
    console.log('purchasePrice :' + purchase_price);
    
    $("#order_cd").val(order_cd);
    $("#supply_cd").val(supply_cd);
  }
  
  /** 발주서 화면 콜백 함수*/
  function fSelectPurchBtnResult(data) {
    if (data.result == "SUCCESS") {
      // 모달 팝업
      gfModalPop("#layer1");
      
      $("#alertmsg").val(data.resultMsg);

      console.log("fSelectPurchBtnResult : " + JSON.stringify(data));
    } else {
      alert(data.resultMsg);
    }
  }
  
  /** 발주지시서 목록 조회 */
  function fsend() {
    var purch_list_no = $("#purchListNo").text();
    var order_cd = $("#order_cd").val();
    var supply_cd = $("#supply_cd").val();
    var purch_date = $("#purchaseDateValue").val();
    var desired_delivery_date = $("#desiredDeliveryDateValue").val();
    var purch_mng_id = $("#purchMngIdValue").val();
   
    console.log('purch_date' + purch_date);
    console.log('desired_delivery_date' + desired_delivery_date);
    console.log('purch_mng_id' + purch_mng_id);
    
    var param = {
        purch_list_no : purch_list_no,
        order_cd : order_cd,
        supply_cd : supply_cd,
        purch_date : purch_date,
        desired_delivery_date : desired_delivery_date,
        purch_mng_id : purch_mng_id
    }
    
    var resultCallback = function(data) {
      fsendResult(data);
    };
    //Ajax실행 방식
    //callAjax("Url",type,return,async or sync방식,넘겨준거,값,Callback함수 이름)
    callAjax("/pcs/sendproc.do", "post", "json", true, param, resultCallback);
  }  
  
  function fsendResult(data) {
    if (data.result == "SUCCESS") {
      alert(data.resultMsg);
      location.reload('');
      console.log("fSelectPurchBtnResult : " + JSON.stringify(data));
    } else {
      alert(data.resultMsg);
    }
  }
</script>
</head>
<body>
    <form id="myForm" action="" method="">
        <input type="hidden" id="currentPage" value="1">
        <input type="hidden" name="order_cd" id="order_cd" value="">
        <input type="hidden" name="supply_cd" id="supply_cd" value="">
        <input type="hidden" name="alertmsg" id="alertmsg" value="">
        <input type="hidden" name="action" id="action" value="">
         
        <!-- 모달 배경 -->
        <div id="mask"></div>
        <div id="wrap_area">
            <h2 class="hidden">header 영역</h2>
            <jsp:include page="/WEB-INF/view/common/header.jsp"></jsp:include>
            <h2 class="hidden">컨텐츠 영역</h2>
            <div id="container">
                <ul>
                    <li class="lnb">
                        <!-- lnb 영역 --> <jsp:include page="/WEB-INF/view/common/lnbMenu.jsp"></jsp:include> <!--// lnb 영역 -->
                    </li>
                    <li class="contents">
                        <!-- contents -->
                        <h3 class="hidden">contents 영역</h3> <!-- content -->
                        <div class="content">
                            <p class="Location">
                                <a href="#" class="btn_set home">메인으로</a>
                                <a href="pcsOrderingoOrder.do" class="btn_nav">구매</a>
                                <span class="btn_nav bold">발주 지시서</span>
                                <a href="../pcs/pcsOrderingOrder.do" class="btn_set refresh">새로고침</a>
                            </p>
                            <p class="conTitle">
                                <span>발주 지시서 목록</span>
                            </p>
                            <div class="divComGrpCodList">
                                <table class="col">
                                    <caption>caption</caption>
                                    <colgroup>
                                        <col width="7%">
                                        <col width="10%">
                                        <col width="25%">
                                        <col width="7%">
                                        <col width="7%">
                                        <col width="6%">
                                        <col width="*">
                                        <col width="10%">
                                        <col width="7%">
                                        <col width="7%">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th scope="col">발주번호</th>
                                            <th scope="col">회사명</th>
                                            <th scope="col">제품명</th>
                                            <th scope="col">브랜드명</th>
                                            <th scope="col">제품수량</th>
                                            <th scope="col">금액</th>
                                            <th scope="col">배송희망날짜</th>
                                            <th scope="col">창고명</th>
                                            <th scope="col">담당자</th>
                                            <th scope="col">발주</th>
                                        </tr>
                                    </thead>
                                    <tbody id="listPcsOrderingOrder"></tbody>
                                </table>
                            </div>
                            <div class="paging_area" id="pcsOrderingOrderPagination"></div>
                        <h3 class="hidden">풋터 영역</h3> <jsp:include page="/WEB-INF/view/common/footer.jsp"></jsp:include>
                    </li>
                </ul>
            </div>
        </div>
        <!-- 모달팝업 -->
        <div id="layer1" class="layerPop layerType2" style="width: 600px;">
            <dl>
                <dt>
                    <strong>발주서</strong>
                </dt>
                <dd class="content">
                    <!-- s : 여기에 내용입력 -->
                    <table class="row">
                        <caption>caption</caption>
                        <colgroup>
                            <col width="120px">
                            <col width="*">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th scope="row">발주코드</th>
                                <td id="purchListNo"></td>
                            </tr>
                            <tr>
                                <th scope="row">회사명</th>
                                <td id="supplyNm"></td>
                            </tr>
                            <tr>
                                <th scope="row">제품명</th>
                                <td id="prodNm"></td>
                            </tr>
                            <tr>
                                <th scope="row">브랜드명</th>
                                <td id="mCtCd"></td>
                            </tr>
                            <tr>
                                <th scope="row">제품수량</th>
                                <td id="purchQty"></td>
                            </tr>
                            <tr>
                                <th scope="row">금액</th>
                                <td id="purchasePrice"></td>
                            </tr>
                            <tr>
                                <th scope="row">발주날짜</th>
                                <td id="purchaseDate"><input type="date" value="" id="purchaseDateValue" style="box-sizing: border-box;border: 1px solid #bbc2cd;padding-left: 2px;height: 34px;width: 100%;" /></td>
                            </tr>
                            <tr>
                                <th scope="row">배송희망날짜</th>
                                <td id="desiredDeliveryDate"><input type="date" value="" id="desiredDeliveryDateValue" style="box-sizing: border-box;border: 1px solid #bbc2cd;padding-left: 2px;height: 34px;width: 100%;" /></td>
                            </tr>
                            <tr>
                                <th scope="row">창고명</th>
                                <td id="warehouseNm"></td>
                            </tr>
                            <tr>
                                <th scope="row">담당자</th>
                                <td id="purchMngId"><input type="text" value="" id="purchMngIdValue" style="box-sizing: border-box;border: 1px solid #bbc2cd;padding-left: 2px;height: 34px;width: 100%;"/></td>
                            </tr>
                        </tbody>
                    </table>
                    <!-- e : 여기에 내용입력 -->
                    <div class="btn_areaC mt30">
                        <a href="" class="btnType blue" id="btnSubmitPurchBtn" name="btn"><span>전송</span></a>
                        <a href="" class="btnType gray" id="btnClosePurchBtn" name="btn"><span>취소</span></a>
                    </div>
                </dd>
            </dl>
            <a href="" class="closePop"><span class="hidden">닫기</span></a>
        </div>
        <!--// 모달팝업 -->
        <!-- 모달팝업 -->
        <div id="layer2" class="layerPop layerType2" style="width: 600px;">
            <dl>
                <dt>
                    <strong>발주서</strong>
                </dt>
                <dd class="content">
                    <!-- s : 여기에 내용입력 -->
                    <table class="row">
                        <caption>caption</caption>
                        <colgroup>
                            <col width="120px">
                            <col width="*">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th scope="row">발주코드</th>
                                <td id="purchListNo"></td>
                            </tr>
                            <tr>
                                <th scope="row">회사명</th>
                                <td id="supplyNm"></td>
                            </tr>
                            <tr>
                                <th scope="row">제품명</th>
                                <td id="prodNm"></td>
                            </tr>
                            <tr>
                                <th scope="row">브랜드명</th>
                                <td id="mCtCd"></td>
                            </tr>
                            <tr>
                                <th scope="row">제품수량</th>
                                <td id="purchQty"></td>
                            </tr>
                            <tr>
                                <th scope="row">금액</th>
                                <td id="purchasePrice"></td>
                            </tr>
                            <tr>
                                <th scope="row">발주날짜</th>
                                <td id="purchaseDate"><input type="date" value="" id="purchaseDateValue" style="box-sizing: border-box;border: 1px solid #bbc2cd;padding-left: 2px;height: 34px;width: 100%;" /></td>
                            </tr>
                            <tr>
                                <th scope="row">배송희망날짜</th>
                                <td id="desiredDeliveryDate"><input type="date" value="" id="desiredDeliveryDateValue" style="box-sizing: border-box;border: 1px solid #bbc2cd;padding-left: 2px;height: 34px;width: 100%;" /></td>
                            </tr>
                            <tr>
                                <th scope="row">창고명</th>
                                <td id="warehouseNm"></td>
                            </tr>
                            <tr>
                                <th scope="row">담당자</th>
                                <td id="purchMngId"><input type="text" value="" id="purchMngIdValue" style="box-sizing: border-box;border: 1px solid #bbc2cd;padding-left: 2px;height: 34px;width: 100%;"/></td>
                            </tr>
                        </tbody>
                    </table>
                    <!-- e : 여기에 내용입력 -->
                    <div class="btn_areaC mt30">
                        <a href="" class="btnType blue" id="btnSubmitPurchBtn" name="btn"><span>전송</span></a>
                        <a href="" class="btnType gray" id="btnClosePurchBtn" name="btn"><span>취소</span></a>
                    </div>
                </dd>
            </dl>
            <a href="" class="closePop"><span class="hidden">닫기</span></a>
        </div>
        <!--// 모달팝업 -->
    </form>
</body>
</html>