<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>공지사항</title>
<jsp:include page="/WEB-INF/view/common/common_include.jsp"></jsp:include>
<script type="text/javascript">
  // 페이징 설정
  var pageSize = 5;
  var pageBlock = 5;
  
  /* OnLoad event */
  $(function() {
    // 공지사항 목록 조회
    selectList();

    /* datepicker설정 */
    // formerDate datepicker
    $('#datetimepicker1').datetimepicker({
    //format : 'L',
    format : 'YYYY-MM-DD',
    formatDate : 'YYYY-MM-DD'
    });

    $('#datetimepicker2').datetimepicker({
    format : 'L',
    useCurrent : false
    });

    $("#datetimepicker1").on("change.datetimepicker", function(e) {
      var date = $("#datetimepicker1").find("input").val()
      $('#datetimepicker2').datetimepicker('minDate', e.date);
    });

    // latterDate datepicker
    $('#datetimepicker3').datetimepicker({
    //format : 'L',
    format : 'YYYY-MM-DD',
    formatDate : 'YYYY-MM-DD'
    });

    $('#datetimepicker4').datetimepicker({
    format : 'L',
    useCurrent : false
    });

    $("#datetimepicker3").on("change.datetimepicker", function(e) {
      var date = $("#datetimepicker3").find("input").val()
      $('#datetimepicker4').datetimepicker('minDate', e.date);
    });

    /* 공지사항 제목 글자 제한 */
    // maxlength로만 처리 시
    // 경고창이 뜨지 않고 유지보수 시 불편하다 판단하여 JavaScript로 처리
    $('#notice_title').keyup(function(e) {

      var limit = 100;
      var count = $(this).val().length;

      if (count > limit) {
        swal('제목은 100자 이하로 작성해 주세요');
        $(this).val($(this).val().substring(0, limit));
        return false;
      }
    });

    /* 공지사항 내용 글자 제한 & 카운트 이벤트 */
    $("#notice_content").keyup(function(e) {

      var count = $('#notice_content').val().length;
      document.getElementById("count").innerHTML = count;

      var limit = 1000;
      var input = $(this).val().length;

      if (input > limit) {
        swal('내용은 1000자 이하로 작성해 주세요');
        $(this).val($(this).val().substring(0, limit));
        count = limit;
        document.getElementById("count").innerHTML = count;
        return false;
      }
    });

    /* 공지사항 작성 모달 이벤트 */
    $('#write_modal_button').click(function() {
      var identifier = 'w';
      fadeInModal(identifier);
      console.log('//')
    });

    /* 공지사항 작성 버튼 이벤트 */
    $('#write_button').click(function() {
      writeNotice();
    });

    // 모달 닫기 버튼 이벤트
    $('#close_button').click(function() {
      gfCloseModal();
    })

    // 공지사항 수정 모달 버튼 이벤트
    $('#modify_modal_button').click(function() {
      var identifier = 'm';
      fadeInModal(identifier);
      console.log('수정')
    });

    // 공지사항 수정 버튼 이벤트
    $('#modify_button').click(function() {
      modifyNotice();
    });

    // 공지사항 삭제 버튼 이벤트
    $('#delete_button').click(function() {
      deleteNotice();
    })

    // 파일 삭제 버튼 이벤트
    $('#delete_file_button').click(function() {
      $('#delete_file_button').hide();
      $('#file_path').val('');
    })
    
     /* 공지사항 검색 버튼 이벤트 */
    $('#search_button').on('click', function() {
      
      isSearch = true;
      var validate = validateDate(); 
      
      if (validate) {
        
        option = $('#option').val();
        keyword = $('#keyword').val();
        formerDate = $("#datetimepicker1").find("input").val();
        latterDate = $("#datetimepicker3").find("input").val();
      
        selectList();
      }
      else {
        return false;
      }
    });

    // onload 끝
  });
  
  var option;
  var keyword;
  var formerDate;
  var latterDate;
  var isSearch;
  
  //날짜검증
  function validateDate() {
    
    var validateFormerDate = $("#datetimepicker1").find('input').val();
    var validateLatterDate = $("#datetimepicker3").find('input').val();
    var currentPage = 1;
    var delimiter = '-';
    var today = new Date();

    // JavsScript는 월이 0부터 시작하므로 +1
    // 오늘 날짜와 latterDate를 비교하기 위해서 형식 맞춰줘야 함
    today = today.getFullYear() + delimiter + ('0' + (today.getMonth() + 1)).slice(-2) + delimiter + ('0' + today.getDate()).slice(-2);
    
    // 날짜가 2개 중 하나라도 설정되면 반드시 2개다 설정되어야 함
    if ((!validateFormerDate && validateLatterDate) && (validateFormerDate && !validateLatterDate)) {
      swal('기간을 설정해 주세요');
      return false;
    } 
    else if (validateFormerDate > validateLatterDate) {
      // validateFormerDate가 validateFormerDate보다 클 경우는 2개의 날짜를 교환
      // google이 날짜검색 시 이 방식을 사용하고 있음
        var temp;
        temp = validateFormerDate;
        validateFormerDate = validateLatterDate;
        validateLatterDate = temp;
        $("#datetimepicker1").find('input').val(validateFormerDate);
        $("#datetimepicker3").find('input').val(validateLatterDate);
    } 
    else if (validateFormerDate > today || validateLatterDate > today ) {
        swal('오늘 이후는 검색할 수 없습니다');
        return false;
    } 
    else {
      return true;
    }
  }
  
  // 이미지 파일 검증
  function validateFile() {
    
    var imgFile = document.getElementById('uploadFile');
    var fileForm = /(.*?)\.(jpg|jpeg|png|bmp)$/;
    var maxSize = 5 * 1024 * 1024; 
    var fileSize = imgFile.files[0].size;
    var fileLength = imgFile.files[0].name.length;
    var maxLength = 100;
    
    if(!imgFile.value.match(fileForm)) {
      swal('이미지 파일만 업로드해 주세요');
      return false;
    }
    else if(fileSize > maxSize) {
      swal('파일은 5MB이하만 업로드 하실 수 있습니다');
      return false;
    }
    else if(fileLength > maxLength) {
      swal('파일명은 100자 이하만 가능합니다')
      return false;
    }
    else {
      return true;
    }
  }

  /* 공지사항 글 작성 null 체크 함수 */
  // reqired가 동작하지 않아서 작성
  function validateIsNull() {

    // 제목, 내용이 입력되었는지 확인
    var title = $('#notice_title').val();
    var content = $('#notice_content').val();
    var auth = $('#notice_auth').val();

    if (!title) {
      swal('제목을  입력해주세요');
      $('#notice_title').focus();
      return false;
    } else if (!content) {
      swal('내용을  입력해주세요');
      $('#notice_content').focus();
      return false;
    } else {
      return true;
    }
  }
  
 
  /* 공지사항 목록 조회 함수 */
  function selectList(currentPage) {
    
    currentPage = currentPage || 1;
    
    // 검색조건이 없을 경우의 파라미터
    var param = {
        currentPage : currentPage,
        pageSize : pageSize
    };
    
    if(isSearch){
        param.option = option;
        keyword = keyword.trim();
        param.keyword = keyword;
        $('#keyword').val(keyword);
        param.formerDate = formerDate;
        param.latterDate = latterDate;
    }
    // 콜백
    var resultCallback = function(result) {
      selectListCallBack(result, currentPage);
    };
    callAjax("/system/notice.do", "post", "text", true, param, resultCallback);
  }

  /* 공지사항 목록 조회 콜백 함수 */
  function selectListCallBack(result, currentPage) {

    // 기존 목록 삭제
    $('#noticeList').empty();

    // 신규 목록 생성
    $("#noticeList").append(result);

    // 리스트 로우의 총 개수 추출
    var totalCount = $("#totalCount").val();

    // 페이지 네비게이션 생성
    var paginationHtml = getPaginationHtml(currentPage, totalCount, pageSize, pageBlock, 'selectList');
    console.log("paginationHtml : " + paginationHtml);
    $("#pagination").empty().append(paginationHtml);

    // 현재 페이지 설정
    $("#currentPageCod").val(currentPage);
  }
  


  /* 공지사항 글 작성 함수 */
  function writeNotice() {
    // 공지사항 글 작성 null 체크
    var validate = validateIsNull();

    if (validate) {
      var title = $('#notice_title').val();
      var content = $('#notice_content').val();
      var auth = $('#notice_auth').val();

      var form = $("#myForm")[0];
      form.enctype = 'multipart/form-data';
      var fileData = new FormData(form);

      // file에 데이터 추가
      fileData.append('title', title);
      fileData.append('content', content);
      fileData.append('auth', auth);

      
      var uploadFile = document.getElementById("uploadFile").files[0];
      // 파일 첨부 여부를 판단하기 위한 변수
      var isFile = false;
     // fileData.append('file', uploadFile.files[0]);
     
      if(uploadFile) {
        var validate = validateFile();
        console.log('파일검증확인', validate);
        if (validate) {
          fileData.append('flie', uploadFile);
        }
        else {
          return false;
        }
      } else {
        fileData.append('isFile', isFile);
      }
     
      // 콜백 함수
      function resultCallback(result) {

        if (result == 1) {
          // fadeOutModal();
          gfCloseModal();
          selectList();

        } else {
          swal('서버에서 에러가 발생했습니다');
        }
      }

      // 파일 업로드 AJAX호출(fileUploadCallback작성 해야 함)
      callAjaxFileUploadSetFormData("/system/writeNotice.do", "post", "json", true, fileData, resultCallback);
    } // validate끝
  };

  /* 공지사항 단건 조회 함수 */
  function selectDetail(notice_id, identifier) {

    var param = {
      notice_id : notice_id
    }

    /* 공지사항 단건 조회 콜백 함수  */
    function resultCallback(result) {

      // 공지사항  작성 모달
      gfModalPop("#layer1");
      initModal(identifier, result);

    }
    callAjax("/system/detailNotice.do", "post", "json", true, param, resultCallback);
  }

  /* 공지사항 작성 ,공지사항 수정 모달 변경 */
  function swapModal(identifier) {

    // 공지사항 작성
    if (identifier == 'w') {

      $('#dt_write').show();
      $('#dt_notice').hide();
      $('.auth_block').show();
      $('#count_cotent').show();

      $('#write_button').show();
      $('#modify_button').hide();
      $('#modify_modal_button').hide();
      $('#delete_button').hide();

      $('#add_file').show();
      $('#datice_date_block').hide();
      $('#notice_title').attr('readonly', false);
      $('#notice_content').attr('readonly', false);
      $('#download_file').hide();
      $('#modify_file').hide();

    }
    // 공지사항 단건 조회
    else if (identifier == 'r') {

      $('#add_file').hide();
      $('#dt_write').hide();
      $('#dt_notice').show();
      $('.auth_block').hide();
      $('#count_cotent').hide();

      $('#write_button').hide();
      $('#modify_button').hide();
      $('#modify_modal_button').show();
      $('#delete_button').show();

      $('#datice_date_block').show();
      $('#notice_title').attr('readonly', true);
      $('#notice_content').attr('readonly', true);

      $('#modify_file').hide();

    }
    // 공지사항 수정
    else if (identifier == 'm') {

      $('#add_file').hide();
      $('#dt_write').show();
      $('#dt_notice').hide();
      $('.auth_block').show();
      $('#count_cotent').show();

      $('#write_button').hide();
      $('#modify_button').show();
      $('#modify_modal_button').hide();
      $('#delete_button').show();
      $('#download_file').hide();

      $('#datice_date_block').hide();
      $('#modify_button').show();
      $('#modify_file').show();
      $('#notice_title').attr('readonly', false);
      $('#notice_content').attr('readonly', false);

      var file = $('#file_name').val();

      if (!file) {
        $('#delete_file_button').hide();
        $('#modify_file').val('');
      }
    }
  }

  /* 공지사항 수정 함수*/
  function modifyNotice() {
    // null 체크
    var validate = validateIsNull();

    if(validate) {
      var notice_id = $('#notice_id').val();
      var title = $("#notice_title").val();
      var content = $("#notice_content").val();
      var auth = $("#notice_auth").val();
      
      var form = $("#myForm")[0];
      form.enctype = 'multipart/form-data';
      var fileData = new FormData(form);
      
      fileData.append('notice_id', notice_id);
      fileData.append('title', title);
      fileData.append('content', content);
      fileData.append('auth', auth);
      
      // 기존 첨부파일 유무 확인
      var file_no = $('#file_no').val();
      var file_name = $('#file_name').val();
      fileData.append('file_nm', file_name);
      
      // 기존 첨부파일 삭제 여부 확인
      var file_path = $('#file_path').val();
      
      // 첨부 파일 변경, 추가 여부 확인
      var modifiedFile = document.getElementById('upload_modify_file').files[0];
      console.log('수정함수공통호출,첨부파일여부확인', modifiedFile)
      
      // file_no이 null이면 원본 글에  파일 없음
      if (file_no && !file_path && !modifiedFile) {
        fileData.append('deleted', 'file_deleted');
        fileData.append('file_no', file_no);
        fileData.append('file_nm', file_name);
      }
      else if ((!file_no && !modifiedFile) || (file_no && !modifiedFile)) { // 첨부파일이 없던 글이,글만 수정되는 경우
        var isFile = 'noFile';
        // 첨부파일이 없던 글은 file_no을 추가해 주어야 함(서버 에러 방지 및 식별용)
        fileData.append('noFile', isFile);
        fileData.append('file_no', 0);
      }
      else if(!file_no && modifiedFile) {// 첨부파일 신규 등록
        fileData.append('added', 'addedFile');
        fileData.append('file_no', 0);
        fileData.append('file', modifiedFile);
      }
      else if (file_no && modifiedFile) { // 글 수정 + 파일 수정/추가
        fileData.append('modified','file_modified');
        fileData.append('file_no', file_no);
        fileData.append('file', modifiedFile);
      }

      // 콜백
      function resultCallback(result) {
        if (result == 1) {
          gfCloseModal();
          selectList();
        } else {
          swal('서버에서 에러가 발생했습니다.')
        }
      }

      callAjaxFileUploadSetFormData("/system/modifyNotice.do", "post", "json", true, fileData, resultCallback);
    }
  }

  /* 공지사항 삭제 함수 */
  function deleteNotice() {
    var isDelete = confirm('정말 삭제하시겠습니까?');

    // file_no, file_nm
    // 삭제
    if (isDelete) {
      var notice_id = $('#notice_id').val();
      var file_no = $('#file_no').val();
      var file_nm = $('#file_name').val();
      
      if(!file_no) {
        file_no = 0;
      }
      
      var param = {
        notice_id : notice_id,
        file_no : file_no,
        file_nm : file_nm
      }

      // 콜백
      function resultCallback(result) {
        if (result == 1) {
          gfCloseModal();
          selectList();
        } else {
          swal('서버에서 에러가 발생했습니다');
        }
      }
      
      callAjax("/system/deleteNotice.do", "post", "text", true, param, resultCallback);
    } else {
      return false;
    }
  }

  // fadeInModal
  function fadeInModal(identifier, notice_id) {

    if (identifier == 'w') {
      // 모달 변경
      swapModal(identifier);
      // 모달 초기화 & 값변경
      initModal(identifier);
      // 모달 팝업
      gfModalPop("#layer1");

    } else if (identifier == 'r') {
      swapModal(identifier);
      // 공지사항 모달 초기화
      initModal(identifier);
      // 공지사항 단건 조회
      selectDetail(notice_id, identifier);
    } else if (identifier == 'm') {
      // 수정은 단건 조회에서 불러온 데이터를 그대로 가지고
      // 모달만 변경시키면 된다.
      // 추가:글자수 카운팅 설정
      swapModal(identifier);
      initModal(identifier);
      var count = $('#notice_content').val().length;
      document.getElementById("count").innerHTML = count;
    }
  }

  // initModal
  // 모달값 초기화 & 값설정
  function initModal(identifier, result) {
    var title = $('#notice_title').val();

    if (identifier == 'w') {
      $('#notice_title').val('');
      $('#notice_content').val('');
      $('#uploadFile').val('');
      $('#notice_auth').val('0');
    } 
    else if (identifier == 'r') {
      console.log('단건조회', result)
      if (result) {
        $('#notice_id').val(result.notice_id);
        $('#notice_title').val(result.title);
        $('#notice_date').text(result.date);
        $('#notice_content').val(result.content);
        $('#notice_auth').val(result.auth);
        $('#modify_file').hide();

        if (result.file_no) {
          $('#download_file').show();
          $('#delete_file_button').show();
          $('#download').attr("href", result.file_relative_path);
          $('#file_name').val(result.file_ofname);
          $('#file_no').val(result.file_no);
          $('#file_path').val(result.file_relative_path);
        }
        else {
            $('#file_no').val('');
            $('#download_file').hide();
        }
      } 
    }
    else if (identifier == 'm') { // 수정모달
      $('#upload_modify_file').val('');
      $('#download_file').hide();
    }
  }
  
</script>
</head>
<body>
  <form id="myForm" action="">
    <input type="hidden" id="currentPageCod" value="1"> 
    <input type="hidden" id="notice_id">
    <input id="file_no" type="hidden">
    <input id="file_path" type="hidden"> 
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
                <a href="#" class="btn_set home">메인으로</a><span class="btn_nav bold">공지사항</span> <a href="javascript:window.location.reload();" class="btn_set refresh">새로고침</a>
              </p>
              <p class="conTitle">
                <span>공지사항</span>
              </p>
              <div class="row">
                <!-- searchbar -->
                <div class="col-lg-6">
                  <div class="input-group">
                    <select style="width: 90px; height: 34px;" id="option">
                      <option value="all" selected>전체</option>
                      <option value="title" id="title">제목</option>
                      <option value="content" id="content">내용</option>
                    </select> <input type="text" class="form-control" aria-label="..." id="keyword" autocomplete="off">
                  </div>
                </div>
                <!-- // searchbar -->
                <!-- datepicker -->
                <div class='col-md-3 col-xs-4'>
                  <div class="form-group">
                    <div class="input-group date" id="datetimepicker1" data-target-input="nearest">
                      <input type="text" class="form-control datetimepicker-input" data-target="#datetimepicker1" style="pointer-events:none;">
                      <div class="input-group-append" data-target="#datetimepicker1" data-toggle="datetimepicker">
                        <div class="input-group-text">
                          <i class="fa fa-calendar"></i>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <span class="divider">~</span>
                <div class='col-md-3 col-xs-4'>
                  <div class="form-group">
                    <div class="input-group date" id="datetimepicker3" data-target-input="nearest">
                      <input type="text" class="form-control datetimepicker-input" data-target="#datetimepicker3" style="pointer-events:none;">
                      <div class="input-group-append" data-target="#datetimepicker3" data-toggle="datetimepicker">
                        <div class="input-group-text">
                          <i class="fa fa-calendar"></i>
                        </div>
                      </div>
                    </div>
                  </div>
                  </div>
                  <!-- // datepicker -->
                  <!-- button -->
                  <div class="btn-group" role="group" aria-label="...">
                    <button type="button" class="btn btn-default" id="search_button">검색</button>
                  </div>
                  <!-- // button -->
                </div>
                <!-- /.row -->
                <div class="divComGrpCodList">
                  <table class="col">
                    <caption>caption</caption>
                    <colgroup>
                      <col width="10%">
                      <col width="50%">
                      <col width="30%">
                      <col width="20%">
                    </colgroup>
                    <thead>
                      <tr>
                        <th scope="col">글번호</th>
                        <th scope="col">제목</th>
                        <th scope="col">작성일</th>
                        <th scope="col">조회수</th>
                      </tr>
                    </thead>
                    <tbody id="noticeList"></tbody>
                  </table>
                </div>
              <div class="paging_area" id="pagination"></div>
              <div class="btn-wrap">
                <c:if test="${sessionScope.userType eq 'E'}">
                  <button type="button" class="btn btn-default" id="write_modal_button">글쓰기</button>
                </c:if>
              </div>
              <h3 class="hidden">풋터 영역</h3>
              <jsp:include page="/WEB-INF/view/common/footer.jsp"></jsp:include>
            </div>
          </li>
        </ul>
        <!--  -->
      </div>
    </div>
    <!-- 공지사항 모달 시작-->
    <div id="layer1" class="layerPop layerType2" style="width: 600px;">
      
      <dl>
        <dt id="dt_write">
          <strong>글쓰기</strong>
        </dt>
        <dt id="dt_notice">
          <strong>공지사항</strong>
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
                <th scope="row">제목</th>
                <td colspan="3"><input type="text" class="inputTxt p100" name="notice_title" id="notice_title" autocomplete="off" placeholder="최대 100자까지 입력 가능합니다" /></td>
              </tr>
              <tr id="datice_date_block">
                <th scope="row">작성시간</th>
                <td colspan="3"><p id="notice_date"></p></td>
              </tr>
              <tr>
                <th scope="row">내용</th>
                <td colspan="3"><textarea class="inputTxt p100" name="notice_content" id="notice_content" placeholder="최대 1000자까지 입력 가능합니다"></textarea>
                  <p class="pull-right" id="count_cotent">
                    <span id="count">0</span>/1000
                  </p>
                </td>
              </tr>
              <tr id="add_file">
                <th scope="row">첨부파일</th>
                <td colspan="3"><input type="file" class="inputTxt p100" id="uploadFile" accept="image/*" /></td>
              </tr>
              <tr id="download_file">
                <th scope="row">첨부파일</th>
                <td style="border-right: none;">
                  
                  <input id="file_name" value="" readonly>
                </td>
                <td style="border-left: none;">
                   <a class="btn" id="download" href="" download>
                     <button type="button" class="btn-default btn-sm">다운로드</button>
                   </a>
                </td>
              <tr>
              <tr id="modify_file">
                <th scope="row">첨부파일 변경</th>
                <td style="border-right: none;"><input type="file" class="btn-default btn-sm" id="upload_modify_file" accept="image/*" /></td>
                <td style="border-left: none;"><button class="btn-default btn-sm" id="delete_file_button" type="button">첨부파일 삭제</button></td>
              <tr>
              <tr class="auth_block">
                <th scope="row">열람권한</th>
                <td colspan="3">
                  <select class="auth_block" id="notice_auth">
                    <option value="0">전체</option>
                    <option value="1">직원</option>
                  </select> 
                </td>
              </tr>
              <tr>
                <td colspan="3" style="position:absolute; top:100%; left:35%; border-right:none;border-left:none">
                  <c:if test="${sessionScope.userType == 'E'}">
                    <div class="btn-group">
                      <button type="button" class="btn-default btn-sm" id="write_button">저장</button>
                      <button type="button" class="btn-default btn-sm" id="modify_button">저장</button>
                      <button type="button" class="btn-default btn-sm" id="modify_modal_button">수정</button>
                      <button type="button" class="btn-default btn-sm" id="delete_button">삭제</button>
                      <button type="button" class="btn-default btn-sm" id="close_button">취소</button>
                    </div>
                  </c:if>
                </td>
              </tr>
            </tbody>
          </table>
        </dd>
      </dl>
      <a class="closePop" id="closePop_button"><span class="hidden">닫기</span></a>
    </div>
    <!-- 공지사항 모달 끝 -->
  </form>
</body>
</html>