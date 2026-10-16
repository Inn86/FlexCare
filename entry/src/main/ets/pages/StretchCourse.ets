@Entry
@Component
struct StretchCourse {
  build() {
    Column() {
      Row() {
        Blank()
        Text('拉伸课程')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('⚙️')
          .fontSize(20)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      Scroll() {
        Column({ space: 16 }) {
          this.CourseCard('颈部侧屈拉伸', '颈部', '僵硬', '3 分钟', '开始训练')
          this.CourseCard('肩胛放松练习', '肩部', '酸胀', '5 分钟', '开始训练')
          this.CourseCard('腰背温和伸展', '腰背', '僵硬', '6 分钟', '开始训练')
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
  CourseCard(title: string, part: string, type: string, duration: string, action: string) {
    Column({ space: 10 }) {
      Row() {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        Text('2D')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')

      Row({ space: 8 }) {
        this.Tag(part, '#E8F5E9', '#2E8B57')
        this.Tag(type, '#F0F4F8', '#666666')
        this.Tag(`建议 ${duration}`, '#F0F4F8', '#666666')
      }
      .width('100%')

      Button(action)
        .width('100%')
        .height(40)
        .backgroundColor('#C8E6C9')
        .fontColor('#2E8B57')
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