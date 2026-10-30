import preferences from '@ohos.data.preferences'
import { LengthMetrics } from '@kit.ArkUI'

interface CheckRecord {
  time: string;
  part: string;
  level: number;
  types: string;
  note: string;
  aiReport?: string;
  onsetTime: string; // 新增
  duration: string;  // 新增
}

@Component
export struct History {
  @State historyList: CheckRecord[] = []
  @Consume('globalRefresh') @Watch('onRefreshChange') globalRefresh: number
  @State showDetailDialog: boolean = false
  @State currentDetail: CheckRecord | null = null

  aboutToAppear() { this.loadData() }
  onRefreshChange() { this.loadData() }

  async loadData() {
    try {
      let context = getContext(this)
      let store = await preferences.getPreferences(context, 'FlexCareData')
      let historyStr = await store.get('history', '[]') as string
      this.historyList = JSON.parse(historyStr)
    } catch (err) {}
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Blank()
          Text('历史记录').fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
          Text('📊').fontSize(20)
        }.width('100%').padding({ top: 16, bottom: 10, left: 16, right: 16 })

        Scroll() {
          Column({ space: 16 }) {
            Row({ space: 12 }) {
              this.StatCard('自查次数', this.historyList.length.toString())
              this.StatCard('完成课程', '0')
              this.StatCard('训练时长', '0 分钟')
            }.width('100%')

            if (this.historyList.length === 0) {
              Text('暂无自查记录，快去自查一下吧！').fontSize(16).fontColor('#999999').margin({ top: 50 })
            } else {
              ForEach(this.historyList, (item: CheckRecord) => {
                this.RecordCard(item)
              }, (item: CheckRecord) => JSON.stringify(item))
            }
          }.padding({ left: 20, right: 20, bottom: 40 })
        }.layoutWeight(1)
      }.width('100%').height('100%')

      if (this.showDetailDialog && this.currentDetail) {
        Column() {
          Column({ space: 16 }) {
            Row() {
              Text('自查与AI报告详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#2E8B57').layoutWeight(1)
              Text('❌').fontSize(18).fontColor('#999999').onClick(() => { this.showDetailDialog = false })
            }.width('100%').margin({ bottom: 10 })

            Scroll() {
              Column({ space: 12 }) {
                Text(`时间：${this.currentDetail.time}`).fontSize(14).fontColor('#666666')
                Text(`部位：${this.currentDetail.part} | 程度：${this.currentDetail.level}`).fontSize(14).fontColor('#666666')
                Text(`发生时间：${this.currentDetail.onsetTime}`).fontSize(14).fontColor('#666666')
                Text(`持续时长：${this.currentDetail.duration}`).fontSize(14).fontColor('#666666')
                Text(`类型：${this.currentDetail.types}`).fontSize(14).fontColor('#666666')
                if (this.currentDetail.note) {
                  Text(`备注：${this.currentDetail.note}`).fontSize(14).fontColor('#666666')
                }

                Divider().color('#EEEEEE').margin({ top: 10, bottom: 10 })

                if (this.currentDetail.aiReport) {
                  Text(this.currentDetail.aiReport).fontSize(15).fontColor('#333333').lineHeight(24).width('100%')
                } else {
                  Text('（该记录没有生成 AI 报告）').fontSize(14).fontColor('#999999')
                }
              }.width('100%').alignItems(HorizontalAlign.Start)
            }.layoutWeight(1).scrollBar(BarState.Off)

            Button('关闭').width('100%').height(44).backgroundColor('#2E8B57').fontColor('#FFFFFF')
              .onClick(() => { this.showDetailDialog = false })
          }
          .width('85%').height('70%').backgroundColor('#FFFFFF').borderRadius(20).padding(24)
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.2)', offsetX: 0, offsetY: 10 })
        }.width('100%').height('100%').backgroundColor('rgba(0,0,0,0.4)').justifyContent(FlexAlign.Center).zIndex(10)
      }
    }.width('100%').height('100%')
  }

  @Builder
  StatCard(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label).fontSize(12).fontColor('#666666')
      Text(value).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#2E8B57')
    }.layoutWeight(1).padding(14).backgroundColor('#FFFFFF').borderRadius(12)
  }

  @Builder
  RecordCard(item: CheckRecord) {
    Column({ space: 10 }) {
      Row() {
        Text(`自查记录 · ${item.time}`).fontSize(14).fontWeight(FontWeight.Bold).layoutWeight(1)
        Text('✅').fontSize(16)
      }.width('100%')

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        this.Tag(item.part, '#E8F5E9', '#2E8B57')
        this.Tag(item.types, '#F0F4F8', '#666666')
        this.Tag(`程度 ${item.level}`, '#F0F4F8', '#666666')
        // 新增的标签
        this.Tag(item.duration, '#F0F4F8', '#666666')
      }.width('100%')

      if (item.note !== '') {
        Text(`备注：${item.note}`).fontSize(14).fontColor('#666666')
      }
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
    .onClick(() => {
      this.currentDetail = item
      this.showDetailDialog = true
    })
  }

  @Builder
  Tag(text: string, bg: string, color: string) {
    Text(text).fontSize(12).padding({ left: 10, right: 10, top: 4, bottom: 4 }).backgroundColor(bg).fontColor(color).borderRadius(12)
  }
}