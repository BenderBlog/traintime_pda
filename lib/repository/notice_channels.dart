// SPDX-License-Identifier: MPL-2.0

class NoticeChannel {
  final String source;
  final String url;
  final String rows;
  const NoticeChannel(this.source, this.url, this.rows);
}

const noticeChannels = [
  NoticeChannel(
    '西电主页',
    'https://notice.xidian.edu.cn/2016lanmuye.jsp?urltype=tree.TreeTempUrl&wbtreeid=1227',
    '.lanmu-list-k li',
  ),
  NoticeChannel(
    '西电主页',
    'https://notice.xidian.edu.cn/2016lanmuye.jsp?urltype=tree.TreeTempUrl&wbtreeid=1235',
    '.lanmu-list-k li',
  ),
  NoticeChannel(
    '就业信息网',
    'https://job.xidian.edu.cn/news/index/tag/tzgg',
    'ul.newsList',
  ),
  NoticeChannel(
    '信息网络中心',
    'https://xxzx.xidian.edu.cn/zxdt/xwgg.htm',
    '.list03 li',
  ),
  NoticeChannel(
    '信息网络中心',
    'https://xxzx.xidian.edu.cn/wlaq/xwgg.htm',
    '.list03 li',
  ),
  NoticeChannel(
    '电子实验中心',
    'https://eelab.xidian.edu.cn/html/notice/',
    '.arclist li',
  ),
  NoticeChannel(
    '计算机实验中心',
    'https://xdjszx.xidian.edu.cn/html/news/',
    '.childinfo li.listtitle',
  ),
  NoticeChannel('数学建模竞赛', 'https://stsy.xidian.edu.cn/tzgg.htm', 'td.gk3 a.c5'),
  NoticeChannel(
    '电子设计竞赛',
    'https://edc.xidian.edu.cn/html/notices/',
    'a.list-group-item',
  ),
  NoticeChannel(
    '计算机设计竞赛',
    'https://jsj.xidian.edu.cn/html/notice/',
    '.list_right > ul > li',
  ),
  NoticeChannel('体育部', 'https://tyb.xidian.edu.cn/tzgg.htm', '.main_list li'),
  NoticeChannel(
    '物理实验中心',
    'https://wlsyzx.xidian.edu.cn/tzgg.htm',
    '.n_list li',
  ),
  NoticeChannel(
    '创新创业学院',
    'https://ie.xidian.edu.cn/sczx/ggtz.htm',
    '.list_box_news li',
  ),
  NoticeChannel(
    '研究生院',
    'https://gr.xidian.edu.cn/tzgg1.htm',
    '.main-right-list li',
  ),
  NoticeChannel(
    '研究生院',
    'https://gr.xidian.edu.cn/yjsy/yjszs.htm',
    '.main-right-list li',
  ),
  NoticeChannel('通信工程学院', 'https://ste.xidian.edu.cn/tzgg.htm', 'a.d-block'),
  NoticeChannel('电子工程学院', 'https://see.xidian.edu.cn/tzgg.htm', '.part2L li'),
  NoticeChannel(
    '计算机科学与技术学院',
    'https://cs.xidian.edu.cn/tzgg.htm', // 学院通知公告
    '.n_wenzhang li',
  ),
  NoticeChannel(
    '计算机科学与技术学院',
    'https://cs.xidian.edu.cn/bkjy/jxtz.htm', // 本科教育：教学通知
    '.n_wenzhang li',
  ),
  NoticeChannel(
    '计算机科学与技术学院',
    'https://cs.xidian.edu.cn/yjsjy/yjstz.htm', // 研究生教育：研究生通知
    '.n_wenzhang li',
  ),
  NoticeChannel(
    '机电工程学院',
    'https://eme.xidian.edu.cn/tz.htm',
    '.nr-right-text li',
  ),
  NoticeChannel(
    '光电工程学院',
    'https://soe.xidian.edu.cn/xwtz/tzgg.htm',
    '.list_box_06 li',
  ),
  NoticeChannel(
    '物理学院',
    'https://phy.xidian.edu.cn/tzgg.htm',
    '.list_box_04 li',
  ),
  NoticeChannel(
    '经济与管理学院',
    'https://sem.xidian.edu.cn/tzgg.htm',
    '.list_box_news li',
  ),
  NoticeChannel(
    '数学与统计学院',
    'https://math.xidian.edu.cn/xwgg/tzgg.htm',
    '.list1 li',
  ),
  NoticeChannel(
    '人文学院',
    'https://rwxy.xidian.edu.cn/index/tzgg.htm',
    '.TextList li',
  ),
  NoticeChannel('外国语学院', 'https://sfl.xidian.edu.cn/tzgg.htm', '.n_list li'),
  NoticeChannel(
    '微电子学院',
    'https://sme.xidian.edu.cn/plus/list.php?tid=6',
    '.childinfo > div:not(.biaoqian) > ul > li',
  ),
  NoticeChannel(
    '生命科学技术学院',
    'https://life.xidian.edu.cn/tzgg.htm',
    '.text-list li',
  ),
  NoticeChannel(
    '空间科学与技术学院',
    'https://sast.xidian.edu.cn/index/tzgg.htm',
    '.erji_main .right li',
  ),
  NoticeChannel(
    '先进材料与纳米科技学院',
    'https://amn.xidian.edu.cn/tzgg.htm',
    '.text-list li',
  ),
  NoticeChannel(
    '网络与信息安全学院',
    'https://ce.xidian.edu.cn/sy/tzgg.htm',
    '.list2 li',
  ),
  NoticeChannel(
    '网络与信息安全学院',
    'https://ce.xidian.edu.cn/sy/bkjy/jxtz.htm',
    '.list2 li',
  ),
  NoticeChannel(
    '人工智能学院',
    'https://sai.xidian.edu.cn/tzgg.htm',
    '.n_right ul.list li',
  ),
  NoticeChannel(
    '人工智能学院',
    'https://sai.xidian.edu.cn/sy/bkspy.htm',
    '.n_list_text li',
  ),
  NoticeChannel(
    '马克思主义学院',
    'https://xdm.xidian.edu.cn/index/tzgg.htm',
    '.ul02 li',
  ),
  NoticeChannel(
    '集成电路学院',
    'https://jcdlyjy.xidian.edu.cn/tzgg1/tzgg.htm',
    '.list_box_news li',
  ),
  NoticeChannel(
    '信息力学与感知工程学院',
    'https://imse.xidian.edu.cn/tzgg.htm',
    '.text-list li',
  ),
  NoticeChannel(
    '网络与继续教育学院',
    'https://xdwy.xidian.edu.cn/tzgg.htm',
    '.list04 li',
  ),
  NoticeChannel('国际教育学院', 'https://sie.xidian.edu.cn/tzgg.htm', '.n_bt li'),
  NoticeChannel(
    '教务处',
    'https://jwc.xidian.edu.cn/tzgg.htm',
    '.main_left .list li',
  ),
  NoticeChannel(
    '科研院',
    'https://ord.xidian.edu.cn/index/zytz.htm',
    '.main_conRCb li',
  ),
  NoticeChannel('党委研究生工作部', 'https://ygb.xidian.edu.cn/tzgg.htm', 'ul.ss li'),
  NoticeChannel(
    '本科生院',
    'https://bksy.xidian.edu.cn/tzgg.htm',
    '.main .wrap .list li',
  ),
  NoticeChannel('国际处', 'https://oice.xidian.edu.cn/tzgg.htm', '.text-list li'),
  NoticeChannel('学工处', 'https://xgc.xidian.edu.cn/tzgg1.htm', '.right-con li'),
  NoticeChannel('工会', 'https://gh.xidian.edu.cn/tzgg.htm', '.n_bt li'),
  NoticeChannel(
    '实验室设备处',
    'https://sys.xidian.edu.cn/tzgg.htm',
    '.list-main-right li',
  ),
  NoticeChannel('公安保卫处', 'https://bwc.xidian.edu.cn/tzgg.htm', '.n_list li'),
  NoticeChannel(
    '校医院',
    'https://xyy.xidian.edu.cn/ywgk/tzgg.htm',
    '.n_right ul.list li',
  ),
  NoticeChannel(
    '资产经营有限公司',
    'https://zcgs.xidian.edu.cn/xwtz/tzgg.htm',
    '.xshd li',
  ),
  NoticeChannel(
    '西电科技园',
    'https://kgb.xidian.edu.cn/gzdt/tzgg.htm',
    '.lm_list li',
  ),
  NoticeChannel(
    '广州研究院',
    'https://gzyjy.xidian.edu.cn/index/tzgg.htm',
    '.list02 li',
  ),
  NoticeChannel(
    '杭州研究院',
    'https://hz.xidian.edu.cn/index/tzgg.htm',
    '.n_notice li',
  ),
  NoticeChannel(
    '青岛研究院',
    'https://qdyjy.xidian.edu.cn/index/tzgg.htm',
    '.main_conRCb li',
  ),
  NoticeChannel(
    '前沿交叉研究院',
    'https://aai.xidian.edu.cn/html/notice/',
    '.childinfo ul > a',
  ),
  NoticeChannel(
    '重庆集成电路创新研究院',
    'https://cqiciri.xidian.edu.cn/tzgg.htm',
    '.n_notice li',
  ),
  NoticeChannel(
    '雷达信号处理重点实验室',
    'https://rsp.xidian.edu.cn/xwgg/tjgg.htm',
    '.list_box_16 li',
  ),
  NoticeChannel(
    '天线与微波技术重点实验室',
    'https://amt.xidian.edu.cn/tzgg.htm',
    '.ny-textlist li',
  ),
];
