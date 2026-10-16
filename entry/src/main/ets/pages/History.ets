@Entry
@Component
struct History {
  build() {
    Column() {
      Row() {
        Text('历史记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('📊')
          .fontSize(20)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16 })

      Scroll() {
        Column({ space: 16 }) {
          // 统计卡片
          Row({ space: 12 }) {
            this.StatCard('自查次数', '12')
            this.StatCard('完成课程', '28')
            this.StatCard('训练时长', '156 分钟')
          }
          .width('100%')

          // 记录列表
          this.RecordCard('今天 10:24', '颈部', '僵硬', '4', '久坐后不适明显', '颈部侧屈拉伸', true)
          this.RecordCard('昨天 18:02', '腰背', '酸胀', '3', '', '腰背温和伸展', false)
        }
        .padding({ left: 20, right: 20, bottom: 40 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  @Builder
  StatCard(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#666666')
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E8B57')
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  RecordCard(time: string, part: string, type: string, level: string, note: string, course: string, finished: boolean) {
    Column({ space: 10 }) {
      Row() {
        Text(`自查记录 · ${time}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(finished ? '✅' : '⭕')
          .fontSize(16)
      }
      .width('100%')

      Row({ space: 8 }) {
        this.Tag(part, '#E8F5E9', '#2E8B57')
        this.Tag(type, '#F0F4F8', '#666666')
        this.Tag(`程度 ${level}`, '#F0F4F8', '#666666')
      }
      .width('100%')

      if (note !== '') {
        Text(`备注：${note}`)
          .fontSize(14)
          .fontColor('#666666')
      }

      Text(`预课程 · ${course} · ${finished ? '已完成' : '未完成'}`)
        .fontSize(13)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Builder
  Tag(text: string, bg: string, color: string) {
    Text(text)
      .fontSize(12)
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(bg)
      .fontColor(color)
      .borderRadius(12)
  }
}