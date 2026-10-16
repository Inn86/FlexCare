import router from '@ohos.router'

@Component
struct FeatureCard {
  title: string = ''
  subtitle: string = ''
  bgColor: string = '#FFFFFF'
  textColor: string = '#333333'
  targetPage: string = ''
  iconPlaceholder: string = ''

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 6 }) {
          Text(this.title)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textColor)
          if (this.subtitle !== '') {
            Text(this.subtitle)
              .fontSize(14)
              .fontColor(this.textColor)
              .opacity(0.8)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 这里先用圆形占位，后续可以换成 Image 组件加载图片
        Circle()
          .width(60)
          .height(60)
          .fill('#FFFFFF')
          .opacity(0.5)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.bgColor)
    .borderRadius(16)
    .onClick(() => {
      if (this.targetPage !== '') {
        router.pushUrl({ url: this.targetPage })
      }
    })
  }
}

@Entry
@Component
struct Index {
  build() {
    Column() {
      // 顶部标题 + 头像
      Row() {
        Column({ space: 4 }) {
          Text('舒展一下')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
          Text('FlexCare')
            .fontSize(20)
            .fontColor('#1A1A1A')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Circle()
          .width(40)
          .height(40)
          .fill('#E0E0E0')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20 })

      // 功能卡片区
      Column({ space: 14 }) {
        // 身体自查（大卡片，绿色背景）
        FeatureCard({
          title: '身体自查',
          subtitle: '',
          bgColor: '#2E8B57',
          textColor: '#FFFFFF',
          targetPage: 'pages/BodyCheck'
        })

        // 拉伸课程（中等卡片，浅绿背景）
        FeatureCard({
          title: '拉伸课程',
          subtitle: '跟上课程，放松身体',
          bgColor: '#E8F5E9',
          textColor: '#1A1A1A',
          targetPage: 'pages/StretchCourse'
        })

        // 拉伸课程 + 历史记录（并排小卡片）
        Row({ space: 14 }) {
          FeatureCard({
            title: '拉伸课程',
            subtitle: '',
            bgColor: '#E8F5E9',
            textColor: '#1A1A1A',
            targetPage: 'pages/StretchCourse'
          }).layoutWeight(1)

          FeatureCard({
            title: '历史记录',
            subtitle: '',
            bgColor: '#F0F4F8',
            textColor: '#1A1A1A',
            targetPage: 'pages/History'
          }).layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16 })

      // 最近自查记录
      Column({ space: 10 }) {
        Row() {
          Text('最近一次自查')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Blank()
          Text('>')
            .fontSize(18)
            .fontColor('#999999')
        }
        .width('100%')

        Text('今天 10:24')
          .fontSize(14)
          .fontColor('#666666')

        Text('颈部 · 僵硬 · 程度 4')
          .fontSize(14)
          .fontColor('#666666')

        Button('继续训练')
          .width('100%')
          .height(44)
          .backgroundColor('#2E8B57')
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/StretchCourse' })
          })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ left: 20, right: 20, top: 14 })

      Blank()

      // 底部导航栏（用简单 Row 模拟）
      Row() {
        this.BottomNavItem('首页', true)
        this.BottomNavItem('自查', false)
        this.BottomNavItem('课程', false)
        this.BottomNavItem('历史', false)
      }
      .width('100%')
      .height(60)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceAround)
      .border({ width: { top: 1 }, color: '#EEEEEE' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  @Builder
  BottomNavItem(label: string, active: boolean) {
    Column({ space: 4 }) {
      Circle()
        .width(24)
        .height(24)
        .fill(active ? '#2E8B57' : '#CCCCCC')
      Text(label)
        .fontSize(12)
        .fontColor(active ? '#2E8B57' : '#999999')
    }
  }
}