import preferences from '@ohos.data.preferences'

interface CheckRecord {
  time: string;
  part: string;
  level: number;
  types: string;
  note: string;
  onsetTime: string;
  duration: string;
}

@Component
export struct HomeView {
  @State latestRecord: CheckRecord | null = null
  // 接收从父组件传过来的切换 Tab 的函数
  onSwitchTab: (index: number) => void = () => {}

  aboutToAppear() {
    this.loadLatestRecord()
  }

  async loadLatestRecord() {
    try {
      let context = getContext(this)
      let store = await preferences.getPreferences(context, 'FlexCareData')
      let historyStr = await store.get('history', '[]') as string
      let historyList: CheckRecord[] = JSON.parse(historyStr)
      if (historyList.length > 0) {
        this.latestRecord = historyList[0]
      } else {
        this.latestRecord = null
      }
    } catch (err) {}
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('舒展一下').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            Text('FlexCare').fontSize(20).fontColor('#1A1A1A')
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          Circle().width(40).height(40).fill('#E0E0E0')
        }.width('100%').padding({ left: 20, right: 20, top: 20 })

        Column({ space: 14 }) {
          // 点击跳转到 自查 (index: 1)
          this.FeatureCard('身体自查', '', '#2E8B57', '#FFFFFF', 1)
          // 点击跳转到 课程 (index: 2)
          this.FeatureCard('拉伸课程', '跟上课程，放松身体', '#E8F5E9', '#1A1A1A', 2)
        }.width('100%').padding({ left: 20, right: 20, top: 16 })

        Column({ space: 10 }) {
          Row() {
            Text('最近一次自查').fontSize(18).fontWeight(FontWeight.Bold)
            Blank()
            // 点击右侧箭头跳转到 历史 (index: 3)
            Text('>').fontSize(18).fontColor('#999999')
          }.width('100%').onClick(() => { this.onSwitchTab(3) })

          if (this.latestRecord) {
            Text(this.latestRecord.time).fontSize(14).fontColor('#666666')
            Text(`${this.latestRecord.part} · ${this.latestRecord.types} · 程度 ${this.latestRecord.level}`)
              .fontSize(14).fontColor('#666666')
          } else {
            Text('暂无自查记录').fontSize(14).fontColor('#999999').margin({ top: 10, bottom: 10 })
          }
        }
        .width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(16).margin({ left: 20, right: 20, top: 14 })
      }.padding({ bottom: 20 })
    }.width('100%').height('100%')
  }

  @Builder
  FeatureCard(title: string, subtitle: string, bg: string, color: string, targetTabIndex: number) {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 6 }) {
          Text(title).fontSize(22).fontWeight(FontWeight.Bold).fontColor(color)
          if (subtitle !== '') {
            Text(subtitle).fontSize(14).fontColor(color).opacity(0.8)
          }
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        Circle().width(60).height(60).fill('#FFFFFF').opacity(0.5)
      }.width('100%')
    }
    .width('100%').padding(20).backgroundColor(bg).borderRadius(16)
    .onClick(() => {
      this.onSwitchTab(targetTabIndex) // 触发父组件的切换
    })
  }
}