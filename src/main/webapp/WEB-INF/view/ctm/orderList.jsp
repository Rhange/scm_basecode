<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>주문이력 조회</title>
<jsp:include page="/WEB-INF/view/common/common_include.jsp"></jsp:include>
<script type="text/javascript">
  //주문이력 화면 페이징 처리
  var pageSizeProduct = 5; //주문이력 화면 페이지 사이즈
  var pageBlockSizeProduct = 5; //주문이력 화면 페이지 블록 갯수

  //OnLoad event
  $(document).ready(function() {
    //주문이력조회
    fOrderHisList();
    //버튼 이벤트 등록
    fRegisterButtonClickEvent();
  });

  /*버튼 이벤트 등록*/
  function fRegisterButtonClickEvent() {
    $('a[name=btn]').click(function(e) {
      e.preventDefault();
      var btnId = $(this).attr('id');
      switch (btnId) {
      case 'searchBtn':
        board_search(); // 검색하기
        break;
      case 'btnSubmitRefund':// 반품하기
        fSubmitRefund();
        break;
      case 'btnCloseModal':
        gfCloseModal(); // 모달닫기 
        break;
      case 'btnSubmitDeposit':
        fSubmitDeposit(); // 입금하기
        break;
        
      }
    });
  }

  /*주문이력 조회*/
  function fOrderHisList(currentPage) {
    currentPage = currentPage || 1;
    var searchKey = document.getElementById("searchKey");

    var param = {
    currentPage : currentPage,
    pageSize : pageSizeProduct
    }
    var resultCallback = function(data) {
      forderHisListResult(data, currentPage);
    };
    callAjax("/ctm/orderHisList.do", "post", "text", true, param, resultCallback);
  }

  /*주문이력 조회 콜백 함수*/
  function forderHisListResult(data, currentPage) {

    console.log("data : " + data);
    //기존 목록 삭제
    $("#orderHisList").empty();
    $("#orderHisList").append(data);
    // 총 개수 추출
    var totalOrder = $("#totalOrder").val();
    //페이지 네비게이션 생성
    var paginationHtml = getPaginationHtml(currentPage, totalOrder, pageSizeProduct, pageBlockSizeProduct, 'fOrderHisList');
    $("#productPagination").empty().append(paginationHtml);
    //현재 페이지 설정
    $("#currentPageProduct").val(currentPage);
  }

  /* 검색 기능*/
  function board_search(currentPage) {
    currentPage = currentPage || 1;
    var searchKey = document.getElementById("searchKey");

    var param = {
    currentPage : currentPage,
    pageSize : pageSizeProduct
    }

    var resultCallback = function(data) {
      forderHisListResult(data, currentPage);
    };
    callAjax("/ctm/orderHisList.do", "post", "text", true, param, resultCallback);
  }

  /* 모달 실행 */
  function fPopModalRefund(order_cd) {
    $("#action").val("R");
    fSelectRefund(order_cd);
  }

  /* 반품 단건 조회*/
  function fSelectRefund(order_cd) {
    var param = {
      order_cd : order_cd
    };
    var resultCallback = function(data) {
      fSelectRefundResult(data);
    };
    callAjax("/ctm/selectRefund.do", "post", "json", true, param, resultCallback);
  }

  // 콜백 함수
  function fSelectRefundResult(data) {
    if (data.result == "SUCCESS") {
      gfModalPop("#layerRefund")
      fInitFormRefund(data.refundInfoModel);
    } else {
      alert(data.resultMsg);
    }
  }

  function fInitFormRefund(object) {
    $("#refund_reason").focus();
    $("#order_cd").val(object.order_cd);
    $("#prod_nm").val(object.prod_nm);
    $("#product_cd").val(object.product_cd);
    $("#refund_amt").val(object.amount); //amount = refund_amt
    $("#addr").val(object.addr);
    $("#refund_cnt").val(object.order_cnt); //order_cnt = refund_cnt
    $("#refund_reason").val(object.refund_reason);
    $("#order_cd").attr("readonly", true);
    $("#prod_nm").attr("readonly", true);
    $("#product_cd").attr("readonly", true);
    $("#refund_amt").attr("readonly", true);
    $("#addr").attr("readonly", true);
    $("#refund_cnt").attr("readonly", true);
    $("#refund_reason").css("background", "#FFFFFF");
    $("#thumbnail").val("");
    $("#tempImg").attr("src", object.file_relative_path);

    $("#btnSubmit").show();
    $("#thumbnail").hide();

  }
  
  //반품 등록
  function fSubmitRefund() {
    var con = confirm("반품신청을 하시겠습니까 ?");
    if (con){
    var resultCallback = function(data) {
      console.log(data);
      fSubmitRefundResult(data);
   }
   callAjax("/ctm/submitRefund.do", "post", "json", true, $("#myForm")
       .serialize(), resultCallback);
    } else {
      alert("취소 하셨습니다.");
    }
  }
    
  //콜백
  function fSubmitRefundResult(data) {
    var currentPage = "1";
    if (data.result == "SUCCESS") {
      alert(data.resultMsg);
      gfCloseModal();
      fOrderHisList(currentPage);
    } else {
      alert(data.resultMsg);
    }
  }
  
  /* 입금 모달 실행 */
  function fPopModalDeposit(order_cd) {
    $("#action").val("D");
    fSelectDeposit(order_cd);
  }

  /* 입금 단건 조회*/
  function fSelectDeposit(order_cd) {
    var param = {
      order_cd : order_cd
    };
    var resultCallback = function(data) {
      fSelectDepositResult(data);
    };
    callAjax("/ctm/selectDeposit.do", "post", "json", true, param, resultCallback);
  }

  // 콜백 함수
  function fSelectDepositResult(data) {
    if (data.result == "SUCCESS") {
      gfModalPop("#layerDeposit")
      fInitFormDeposit(data.depositInfoModel);
    } else {
      alert(data.resultMsg);
    }
  }

  function fInitFormDeposit(object) {
    $("#DeOrder_cd").val(object.order_cd);
    $("#DeProd_nm").val(object.prod_nm);
    $("#DeOrder_cnt").val(object.order_cnt);
    $("#DeAmount").val(object.amount); //amount = refund_amt
    $("#DeOrder_cd").attr("readonly", true);
    $("#DeProd_nm").attr("readonly", true);
    $("#DeOrder_cnt").attr("readonly", true);
    $("#DeAmount").attr("readonly", true);
    $("#btnDeposit").show();
  }
  
  //입금 처리
  function fSubmitDeposit() {
    var con = confirm("입금 하시겠습니까 ?");
    if (con){
    var resultCallback = function(data) {
      console.log(data);
      fSubmitDepositResult(data);
   }
   callAjax("/ctm/submitDeposit.do", "post", "json", true, $("#myForm")
       .serialize(), resultCallback);
    } else {
      alert("취소 하셨습니다.");
    }
  }
    
  //콜백
  function fSubmitDepositResult(data) {
    var currentPage = "1";
    if (data.result == "SUCCESS") {
      alert(data.resultMsg);
      gfCloseModal();
      fOrderHisList(currentPage);
    } else {
      alert(data.resultMsg);
    }
  }
</script>
</head>
<body>
  <form id="myForm" action="" method="">
    <input type="hidden" id="currentPageProduct" value="1"> <input type="hidden" id="currentPageProduct" value="1"> <input type="hidden" name="action" id="action" value="">
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
                <a href="/system/notice.do" class="btn_set home">메인으로</a> <a class="btn_nav">주문</a> <span class="btn_nav bold">주문이력 조회</span> <a href="" class="btn_set refresh">새로고침</a>
              </p>
              <p class="conTitle">
                <span>주문이력 조회</span>
              </p>
              <div class="ProductList">
                <div class="conTitle row" style="float: left; width: 100%; display: flex; justify-content: flex-end;">
                  <!-- datepicker -->
                  <div class='col-md-3 col-xs-4'>
                    <div class="form-group">
                      <div class="input-group date" id="datetimepicker1" data-target-input="nearest">
                        <input type="text" class="form-control datetimepicker-input" data-target="#datetimepicker1" value="">
                        <div class="input-group-append" data-target="#datetimepicker1" data-toggle="datetimepicker">
                          <div class="input-group-text">
                            <i class="fa fa-calendar"></i>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <span class="divider" style="top: 35%; left: 68.8%;">~</span>
                  <div class='col-md-3 col-xs-4'>
                    <div class="form-group">
                      <div class="input-group date" id="datetimepicker3" data-target-input="nearest">
                        <input type="text" class="form-control datetimepicker-input" data-target="#datetimepicker3" value="">
                        <div class="input-group-append" data-target="#datetimepicker3" data-toggle="datetimepicker">
                          <div class="input-group-text">
                            <i class="fa fa-calendar"></i>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <!-- // datepicker -->
                  <a href="" class="btnType blue" id="searchBtn" name="btn"> <span>검 색</span>
                  </a>
                </div>
                <table class="col">
                  <caption>caption</caption>
                  <colgroup>
                    <col width="12%">
                    <col width="10%">
                    <col width="10%">
                    <col width="5%">
                    <col width="5%">
                    <col width="10%">
                    <col width="13%">
                    <col width="13%">
                    <col width="7%">
                    <col width="5%">
                    <col width="5%">
                    <col width="5%">
                  </colgroup>
                  <thead>
                    <tr>
                      <th scope="col">제품명</th>
                      <th scope="col">제품코드</th>
                      <th scope="col">품목명</th>
                      <th scope="col">주문번호</th>
                      <th scope="col">주문수량</th>
                      <th scope="col">결제금액</th>
                      <th scope="col">구매일자</th>
                      <th scope="col">배송희망날짜</th>
                      <th scope="col">배송상태</th>
                      <th scope="col">입금</th>
                      <th scope="col">반품</th>
                      <th scope="col">구매확정</th>
                    </tr>
                  </thead>
                  <tbody id="orderHisList"></tbody>
                </table>
              </div>
              <div class="paging_area" id="productPagination"></div>
          </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- 반품 모달 -->
    <div id="layerRefund" class="layerPop layerType2" style="width: 1300px;">
      <dl>
        <dt>
          <strong>반 품</strong>
        </dt>
        <dd class="content">
          <table class="row">
            <caption>caption</caption>
            <colgroup>
              <col width="120px">
              <col width="*">
              <col width="120px">
              <col width="*">
            </colgroup>
            <tbody>
              <tr>
                <th scope="row">제품 이미지</th>
                <th scope="row">주문코드</th>
                <td><input type="text" name="order_cd" id="order_cd" /></td>
                <th scope="row">반품사유</th>
              </tr>
              <tr>
                <td rowspan = "5" style="text-align:center; width:300px; hight:300px;">
                  <img id="tempImg" style="object-fit: cover; max-width:100%; max-hight:100%;" src="/images/admin/comm/no_image.png" alt="제품사진미리보기">
                </td>
                <th scope="row">제품명</th>
                <td><input type="text" name="prod_nm" id="prod_nm" /></td> 
                <td colspan="3" rowspan="5"><textarea class="ui-widget ui-widget-content ui-corner-all" 
                                                      id="refund_reason" maxlength="200" name="refund_reason" style="height: 200px; length: 200px; outline: none; resize: none;" 
                                                      placeholder="여기에  반품사유를 적어주세요.(200자 이내)"></textarea></td>
              </tr>
              <tr>
                <th scope="row">제품코드</th>
                <td><input type="text" name="product_cd" id="product_cd" /></td>
                </tr>
              <tr>
                <th scope="row">환불금액</th>
                <td><input type="text" name="refund_amt" id="refund_amt" /></td>
              </tr>
              <tr>
                <th scope="row">상세주소</th>
                <td><input type="text" name="addr" id="addr" /></td>
              </tr>
              <tr>
                <th scope="row">반품수량</th>
                <td><input type="text" name="refund_cnt" id="refund_cnt" /></td>
              </tr>
              <tr>
              <td class="thumb">
                            <span> 
                <input name="thumbnail" type="file" id="thumbnail" accept="image/* " required>
    
                    <!-- 파일 미리보기 스크립트 영역 -->
                       <script>
                       var file = document.querySelector('#thumbnail');
                    
                       file.onchange = function () { 
                           var fileList = file.files ;
                           
                           // 읽기
                           var reader = new FileReader();
                           reader.readAsDataURL(fileList [0]);
                           //로드 한 후
                           reader.onload = function  () {
                               //로컬 이미지를 보여주기
                               
                               //썸네일 이미지 생성
                               var tempImage = new Image(); //drawImage 메서드에 넣기 위해 이미지 객체화
                               tempImage.src = reader.result; //data-uri를 이미지 객체에 주입
                               tempImage.onload = function() {
                                   //리사이즈를 위해 캔버스 객체 생성
                                   var canvas = document.createElement('canvas');
                                   var canvasContext = canvas.getContext("2d");
                                   
                                   //캔버스 크기 설정
                                   canvas.width = 300; //가로 300px
                                   canvas.height = 300; //세로 300px
                                   
                                   
                                   //이미지를 캔버스에 그리기
                                   canvasContext.drawImage(this, 0, 0, 300, 300);
                                   //캔버스에 그린 이미지를 다시 data-uri 형태로 변환
                                   var dataURI = canvas.toDataURL("image/jpeg");
                                   
                                   //썸네일 이미지 보여주기
                                   document.querySelector('#tempImg').src = dataURI;
                               };
                           }; 
                       };
                                </script>
                                <!-- 파일 미리보기 스크립트 영역 끝 -->
                                </span>
                 </td>
              </tr>
            </tbody>
          </table>
          <div class="btn_areaC mt30">
            <a href="" class="btnType blue" id="btnSubmitRefund" name="btn"><span>등록</span></a> <a href="" class="btnType gray" id="btnCloseModal" name="btn"><span>닫기</span></a>
          </div>
        </dd>
      </dl>
      <a href="" class="closePop" id="btnClose" name="btn"><span class="hidden">닫기</span></a>
    </div>
    
    <!-- 입금 모달 -->
    <div id="layerDeposit" class="layerPop layerType2" style="width: 700px;">
      <dl>
        <dt>
          <strong>반 품</strong>
        </dt>
        <dd class="content">
          <table class="row">
            <caption>caption</caption>
            <colgroup>
              <col width="120px">
              <col width="*">
              <col width="120px">
              <col width="*">
            </colgroup>
            <tbody>
              <tr>
                <th scope="row">주문코드</th>
                <td><input type="text" name="DeOrder_cd" id="DeOrder_cd" /></td>
              </tr>
              <tr>
                <th scope="row">제품명</th>
                <td><input type="text" style="width:500px;"name="DeProd_nm" id="DeProd_nm" /></td>
              </tr>
              <tr>
                <th scope="row">주문수량</th>
                <td><input type="text" name="DeOrder_cnt" id="DeOrder_cnt" /></td> 
              </tr>
              <tr>
                <th scope="row">결제금액</th>
                <td><input type="text" name="DeAmount" id="DeAmount" /></td>
              </tr>
            </tbody>
          </table>
          <div class="btn_areaC mt30">
            <a href="" class="btnType blue" id="btnSubmitDeposit" name="btn"><span>입금</span></a> <a href="" class="btnType gray" id="btnCloseModal" name="btn"><span>닫기</span></a>
          </div>
        </dd>
      </dl>
      <a href="" class="closePop" id="btnClose" name="btn"><span class="hidden">닫기</span></a>
    </div>
  </form>
</body>
</html>