import router from '@ohos.router'
@Entry
@Component
struct BodyCheck {
  @State selectedPart: string = '颈部'
  @State painLevel: number = 4
  @State discomfortType: string = '僵硬'
  @State note: string = ''

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('<')
          .fontSize(24)
          .onClick(() => { router.back() })
        Blank()
        Text('身体自查')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('📝')  // 图标占位
          .fontSize(20)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      Scroll() {
        Column({ space: 20 }) {
          // 人体图占位（用文字代替，后续替换为 Image）
          Column() {
            Text('👤 人体部位示意图')
              .fontSize(16)
              .fontColor('#999999')
            Text('（点击选择身体部位，如颈部、肩部、腰背等）')
              .fontSize(12)
              .fontColor('#BBBBBB')
          }
          .width('100%')
          .height(300)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)

          // 不适程度
          Column({ space: 8 }) {
            Text('不适程度')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Slider({
              value: this.painLevel,
              min: 0,
              max: 10
            })
              .width('100%')
              .onChange((value: number) => {
                this.painLevel = Math.round(value)
              })
            Row() {
              Text('0').fontSize(12).fontColor('#999999')
              Blank()
              Text(this.painLevel.toString()).fontSize(14).fontColor('#2E8B57')
              Blank()
              Text('10').fontSize(12).fontColor('#999999')
            }
            .width('100%')
          }
          .width('100%')

          // 不适类型
          Column({ space: 10 }) {
            Text('不适类型')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)

            Row({ space: 10 }) {
              this.TypeChip('酸胀')
              this.TypeChip('僵硬')
              this.TypeChip('牵拉感')
              this.TypeChip('刺痛')
            }
          }
          .width('100%')

          // 备注
          Column({ space: 8 }) {
            Text('备注')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            TextArea({ placeholder: '补充说明，仅用于记录' })
              .width('100%')
              .height(80)
              .backgroundColor('#F7F8FA')
              .onChange((value: string) => {
                this.note = value
              })
          }
          .width('100%')

          // 生成按钮
          Button('生成自查记录')
            .width('100%')
            .height(48)
            .backgroundColor('#2E8B57')
            .fontColor('#FFFFFF')
            .onClick(() => {
              // 后续实现保存逻辑
              console.info(`部位:${this.selectedPart}, 程度:${this.painLevel}, 类型:${this.discomfortType}, 备注:${this.note}`)
            })
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
  TypeChip(label: string) {
    Text(label)
      .fontSize(14)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.discomfortType === label ? '#D0F0D0' : '#FFFFFF')
      .fontColor(this.discomfortType === label ? '#2E8B57' : '#666666')
      .borderRadius(20)
      .onClick(() => {
        this.discomfortType = label
      })
  }
}