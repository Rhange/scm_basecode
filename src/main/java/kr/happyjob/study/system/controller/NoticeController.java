package kr.happyjob.study.system.controller;

import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.happyjob.study.system.model.NoticeModel;
import kr.happyjob.study.system.service.NoticeService;

@Controller
@RequestMapping("/system/")
public class NoticeController {
	
	@Autowired
	NoticeService noticeService;
	
	// Set logger
	private final Logger log = LogManager.getLogger(this.getClass());

	
	
	// 공지사항 화면
	@RequestMapping(value="notice.do", method=RequestMethod.GET)
//	public String init(@RequestParam Map<String, Object> param, HttpSession session) throws Exception {
	  public String notice() throws Exception {

		//String loginID = (String) session.getAttribute("loginId");
		//param.put("loginID", loginID);
		//System.out.println(loginID);
//		paramMap.put("writer", loginID);
		
		return "system/notice";
	}
	
	// 공지사항 목록 조회(기본, 검색)
	@RequestMapping(value="notice.do", method=RequestMethod.POST)
	public String selectNotice(@RequestParam Map<String, Object> param, Model model, HttpSession session)throws Exception {
	  
	  System.out.println("공지사항 목록 조회 파라미터: " + param);
	  
	  // 현재 페이지 번호
	  int currentPage = Integer.parseInt((String) param.get("currentPage"));
	  
	  // 한 페이지에 보일 로우의 개수
	  int pageSize = Integer.parseInt((String)param.get("pageSize"));
	  
	  // 페이지 시작 로우 번호
	  int pageIndex = (currentPage - 1) * pageSize;
	  
	  param.put("pageIndex", pageIndex);
	  param.put("pageSize", pageSize);
	  
	  // 총 로우의 개수
//	  int totalCount = noticeService.countNoticeList();
	  int totalCount;
	  
	  // 권한 
	  String userType = (String) session.getAttribute("userType");
	  
	  int auth;
	  // E = SCM, F = PCS, F = DLV >> 2(직원)
	  // J = 고객
	  
	  // 비교할 때 주의!! == 이 아니다. 정리하기
	  // 직원은 auth 0, 2를 조회
	  // 고객은 auth 0, 1을 조회
	  
	  switch(userType) {
	    // switch에서 or사용하기. 정리하기
	    case "E" :
	    case "F" :
	    case "G" :
	      auth = 2;
	      break;
	      
	    case "J" :
	      auth = 1;
	      break;
	      
	     default:
	      auth = 0;
	      break;
	  }
	   
	  System.out.println("권한확인switch:" +  auth);
	  
	  param.put("auth", auth);
	  
	  // 검색어 유무 확인
	  if(!param.containsKey("opton")) {
	    totalCount = noticeService.countNoticeList();
	  }
	  else {
	    
	    String option = (String) param.get("option");
      String keyword = (String) param.get("keyword");
      String formerDate = (String) param.get("formerDate");
      String latterDate = (String) param.get("latterDate");
      
      param.put("option", option);
      param.put("keyword", keyword);
      param.put("formerDate", formerDate);
      param.put("latterDate", latterDate);
      
      totalCount = noticeService.countConditionList();
	    
	  }
	  
	  
	  List<NoticeModel> noticeList = noticeService.selectNoticeList(param); 
	  
	  model.addAttribute("noticeList", noticeList);
	  model.addAttribute("totalCount", totalCount);
	  model.addAttribute("pageSize", pageSize);
	  model.addAttribute("currentPage", currentPage);
	  
	  
	  return "/system/noticeList";
	}
	
	
	// 공지사항 작성
	@ResponseBody
	@RequestMapping(value="writeNotice.do", method=RequestMethod.POST)
	public int insertNotice(@RequestParam Map<String, Object> param) throws Exception {
	  System.out.println("공지사항 작성 parameter확인:" + param);
	  
	  int auth = Integer.parseInt((String) param.get("auth"));
	  
	  param.put("auth", auth);
	  
	  int result = noticeService.insertNotice(param);
	 
	  
	  return result;
	}
	
	// 공지사항 단건 조회
	@ResponseBody
	@RequestMapping(value="detailNotice.do", method=RequestMethod.POST)
	public NoticeModel selectDetailNotice(@RequestParam Map<String, Object> param) throws Exception {
//	  public NoticeModel selectDetailNotice(@RequestParam Map<String, Object> notice_id) {
	  
	  int notice_id = Integer.parseInt((String) param.get("notice_id"));
	  
	  System.out.println("nitic_id확인:" + notice_id);
	  
	  // 조회수 증가
	  int updateViewCount = noticeService.updateViewCount(param);
	  
	  NoticeModel notice;
	  
	  if(updateViewCount == 1) {
	    notice = noticeService.selectNoticeDetail(notice_id);
	  } else {
	    log.info("조회수 증가 실패");
	    return null;
	  }
	  
	  return notice;
	}
	
	// 공지사항 수정
	@ResponseBody
	@RequestMapping(value="modifyNotice.do", method=RequestMethod.POST)
	public int updateNotice(@RequestParam Map<String, Object> param) throws Exception {
// 파라미터를 int가 아니라 map으로 던져보자
	  int auth = Integer.parseInt((String)param.get("auth"));
	  param.put("auth", auth);
	  
	  int result = noticeService.updateNotice(param);
	  
	  return result;
	}
	
	// 공지사항 삭제
	@ResponseBody
	@RequestMapping(value="deleteNotice.do", method=RequestMethod.POST)
	public int deleteNotice(@RequestParam Map<String, Object> param) throws Exception {
	  
	  int result = noticeService.deleteNotice(param);
	  
	  return result;
	}
	
	
	
	// 공지사항 상세 조회
//	@RequestMapping("detailNotice.do")
//	@ResponseBody
//	public Map<String,Object> detailNotice(Model model, @RequestParam Map<String, Object> paramMap, HttpServletRequest request, HttpServletResponse response, HttpSession session) throws Exception {
//		
//		//System.out.println("상세정보 보기를 위한 param에서 넘어온 값을 찍어봅시다.: " + paramMap);
//		  logger.info("+ Start " + className + ".detailNotice");
//		  logger.info("   - paramMap : " + paramMap);
//		  
//		String result="";
//		
//		// 선택된 게시판 1건 조회 
//		NoticeModel detailNotice = noticeService.noticeDetail(paramMap);
//		
//		if(detailNotice != null) {
//			result = "SUCCESS";  // 성공시 찍습니다. 
//		}else {
//			result = "FAIL / 불러오기에 실패했습니다.";  // null이면 실패입니다.
//		}
//		
//		Map<String, Object> resultMap = new HashMap<String, Object>();
//		resultMap.put("resultMsg", result); // success 용어 담기 
//		resultMap.put("result", detailNotice); // 리턴 값 해쉬에 담기 
//		//resultMap.put("resultComments", comments);
//		System.out.println(detailNotice);
//		
//		logger.info("+ End " + className + ".detailNotice");
//	    
//	    return resultMap;
//	}
//	
//	// 공지사항 신규등록, 업데이트
//	@RequestMapping("noticeSave.do")
//	@ResponseBody
//	public Map<String, Object> noticeSave(Model model, @RequestParam Map<String, Object> paramMap, HttpServletRequest request, HttpServletResponse response, HttpSession session) throws Exception {
//		
//		logger.info("+ Start " + className + ".noticeSave");
//		logger.info("   - paramMap : " + paramMap);
//		
//		String action = (String)paramMap.get("action");
//		String resultMsg = "";
//		
//		// 사용자 정보 설정
//		paramMap.put("loginID", session.getAttribute("loginId"));
//		if ("I".equals(action)) {
//			// 그룹코드 신규 저장
//			noticeService.insertNotice(paramMap);
//			resultMsg = "SUCCESS";
//		} else if("U".equals(action)) {
//			// 그룹코드 수정 저장
//			noticeService.updateNotice(paramMap);
//			resultMsg = "UPDATED";
//			System.out.println(paramMap);
//		} else {
//			resultMsg = "FALSE : 등록에 실패하였습니다.";
//		}
//		
//		//결과 값 전송
//		Map<String, Object> resultMap = new HashMap<String, Object>();
//		resultMap.put("resultMsg", resultMsg);
//	    
//	    return resultMap;
//	}
//	
//	// 공지사항 삭제
//	@RequestMapping("noticeDelete.do")
//	@ResponseBody
//	public Map<String, Object> noticeDelete(Model model, @RequestParam Map<String, Object> paramMap, HttpServletRequest request,
//			HttpServletResponse response, HttpSession session) throws Exception {
//		
//		logger.info("+ Start " + className + ".noticeDelete");
//		logger.info("   - paramMap : " + paramMap);
//
//		String result = "SUCCESS";
//		String resultMsg = "삭제 되었습니다.";
//		
//		// 그룹코드 삭제
//		noticeService.deleteNotice(paramMap);
//		
//		Map<String, Object> resultMap = new HashMap<String, Object>();
//		resultMap.put("result", result);
//		resultMap.put("resultMsg", resultMsg);
//		
//		logger.info("+ End " + className + ".noticeDelete");
//		
//		return resultMap;
//	}
//	
}
