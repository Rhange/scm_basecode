package kr.happyjob.study.scm.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.happyjob.study.scm.model.SupplierInfoModel;
import kr.happyjob.study.scm.service.SupplierInfoService;

@Controller
@RequestMapping("/scm")
public class SupplierInfoController {
  @Autowired //묶어준다
  SupplierInfoService supplierInfoService;
  
  
  @RequestMapping("supplierInfo.do")
  public String supplierInfo(Model model, @RequestParam Map<String, Object> paramMap, HttpServletRequest request,
      HttpServletResponse response, HttpSession Session) throws Exception{
 
    return "scm/supplierInfo";
  }
  
  //공급처 조회
  @RequestMapping("supplierList.do")
  public String supplierList(Model model, @RequestParam Map<String, Object> paramMap, HttpServletRequest request,
      HttpServletResponse response, HttpSession session) throws Exception{
    
    int currentPage = Integer.parseInt((String)paramMap.get("currentPage"));  // 현재 페이지 번호
    int pageSize    = Integer.parseInt((String)paramMap.get("pageSize"));      // 페이지 사이즈
    int pageIndex   = (currentPage -1)*pageSize;                  // 페이지 시작 row 번호
    
    paramMap.put("pageIndex", pageIndex);
    paramMap.put("pageSize", pageSize);
    
    // 공급처 목록 조회
    List<SupplierInfoModel> supplierInfoModelList = supplierInfoService.getSupplierInfo(paramMap);
    model.addAttribute("supplierInfoModelList", supplierInfoModelList);
    
    // 공급처 목록 카운트 조회
    int totalCount = supplierInfoService.countSupplierInfo(paramMap);
    model.addAttribute("totalCountSupplier", totalCount);
    
    model.addAttribute("pageSize", pageSize);
    model.addAttribute("currentPage",currentPage);  
    
    return "scm/supplierList";
  }
  
  //제품목록 조회
  @RequestMapping("supplierProList.do")
  public String supplierProList(Model model, @RequestParam Map<String, Object> paramMap, HttpServletRequest request,
      HttpServletResponse response, HttpSession session) throws Exception{
    
    int currentPage = Integer.parseInt((String)paramMap.get("currentPage"));  // 현재 페이지 번호
    int pageSize = Integer.parseInt((String)paramMap.get("pageSize"));      // 페이지 사이즈
    int pageIndex = (currentPage-1)*pageSize;                 // 페이지 시작 row 번호
    
//    System.out.println("paramMap : " + paramMap);
    
    paramMap.put("pageIndex", pageIndex);
    paramMap.put("pageSize", pageSize);
   
    
    // 제품 목록 조회
    List<SupplierInfoModel> supplierProModelList = supplierInfoService.getSupplierProInfo(paramMap);
    model.addAttribute("supplierProModelList", supplierProModelList);
    
    // 제품 목록 카운트 조회
    int totalCount = supplierInfoService.countSupplierProInfo(paramMap);
    model.addAttribute("totalCountPro", totalCount);
    
    model.addAttribute("pageSize", pageSize);
    model.addAttribute("currentPage",currentPage);
    
    
    return "scm/supplierProList";
  }
  
  //공급처 단건 조회
  @RequestMapping("selectSupplierDetail.do")
  @ResponseBody
  public Map<String, Object> selectSupplierDetail (Model model, @RequestParam Map<String, Object> paramMap, HttpServletRequest request,
      HttpServletResponse response, HttpSession session) throws Exception{

    String result = "SUCCESS";
    String resultMsg = "조회 되었습니다.";
    
    SupplierInfoModel supplierInfoModel = supplierInfoService.selectSupplierDetail(paramMap);
    
    Map<String, Object> resultMap = new HashMap<String, Object>();
    resultMap.put("result", result);
    resultMap.put("resultMsg", resultMsg);
    resultMap.put("supplierInfoModel", supplierInfoModel);
    
    System.out.println(resultMap);
    return resultMap;
  }
  
//납품 업체 저장
 @RequestMapping("saveSupplier.do")
 @ResponseBody
 public Map<String, Object> saveSupplier (Model model, @RequestParam Map<String, Object> paramMap, HttpServletRequest request,
     HttpServletResponse response, HttpSession session) throws Exception{
   
   String action = (String)paramMap.get("action");
   
   String result = "SUCCESS";
   String resultMsg = "";
   
   if("I".equals(action)){
     //납품 업체 등록
     supplierInfoService.insertSupplier(paramMap);
     resultMsg = "등록 완료";
   } else if("U".equals(action)){
     //납품 업체 수정
     supplierInfoService.updateSupplier(paramMap);
     resultMsg = "수정 완료";
   } else if("D".equals(action)){
     //납품 업체 삭제
     supplierInfoService.deleteSupplier(paramMap);
     resultMsg = "삭제 완료";
   }
   else{
     result = "FALSE";
     resultMsg = "저장 실패";
   }
   
   Map<String, Object> resultMap = new HashMap<String, Object>();
   resultMap.put("result", result);
   resultMap.put("resultMsg", resultMsg);
   
   return resultMap;
 }
  
}
