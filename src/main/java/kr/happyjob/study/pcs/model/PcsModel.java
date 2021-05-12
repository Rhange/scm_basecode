package kr.happyjob.study.pcs.model;

import java.util.Date;

public class PcsModel {
  // 발주번호
  public String purch_list_no;
  // 제품명
  public String prod_nm;
  // 대분류 품목명
  public String l_ct_cd;
  // 발주수량
  public int purch_qty;
  // 장비구매액
  public int purchase_price;
  // 발주총량
  public int purch_total_amt;
  // 배송희망날짜
  public Date desired_delivery_date;
  // 창고명
  public String warehouse_nm;
  // 구매담당자명
  public String purch_mng_id;
  // 창고코드
  public String warehouse_cd;
  // 공급사이름
  public String supply_nm;
  // 주문코드
  public String order_cd;
  // 상태
  public String state;
  // 발주날짜
  public Date direction_date;
  public String getPurch_list_no() {
    return purch_list_no;
  }
  public void setPurch_list_no(String purch_list_no) {
    this.purch_list_no = purch_list_no;
  }
  public String getProd_nm() {
    return prod_nm;
  }
  public void setProd_nm(String prod_nm) {
    this.prod_nm = prod_nm;
  }
  public String getL_ct_cd() {
    return l_ct_cd;
  }
  public void setL_ct_cd(String l_ct_cd) {
    this.l_ct_cd = l_ct_cd;
  }
  public int getPurch_qty() {
    return purch_qty;
  }
  public void setPurch_qty(int purch_qty) {
    this.purch_qty = purch_qty;
  }
  public int getPurchase_price() {
    return purchase_price;
  }
  public void setPurchase_price(int purchase_price) {
    this.purchase_price = purchase_price;
  }
  public int getPurch_total_amt() {
    return purch_total_amt;
  }
  public void setPurch_total_amt(int purch_total_amt) {
    this.purch_total_amt = purch_total_amt;
  }
  public Date getDesired_delivery_date() {
    return desired_delivery_date;
  }
  public void setDesired_delivery_date(Date desired_delivery_date) {
    this.desired_delivery_date = desired_delivery_date;
  }
  public String getWarehouse_nm() {
    return warehouse_nm;
  }
  public void setWarehouse_nm(String warehouse_nm) {
    this.warehouse_nm = warehouse_nm;
  }
  public String getPurch_mng_id() {
    return purch_mng_id;
  }
  public void setPurch_mng_id(String purch_mng_id) {
    this.purch_mng_id = purch_mng_id;
  }
  public String getWarehouse_cd() {
    return warehouse_cd;
  }
  public void setWarehouse_cd(String warehouse_cd) {
    this.warehouse_cd = warehouse_cd;
  }
  public String getSupply_nm() {
    return supply_nm;
  }
  public void setSupply_nm(String supply_nm) {
    this.supply_nm = supply_nm;
  }
  public String getOrder_cd() {
    return order_cd;
  }
  public void setOrder_cd(String order_cd) {
    this.order_cd = order_cd;
  }
  public String getState() {
    return state;
  }
  public void setState(String state) {
    this.state = state;
  }
  public Date getDirection_date() {
    return direction_date;
  }
  public void setDirection_date(Date direction_date) {
    this.direction_date = direction_date;
  }
}