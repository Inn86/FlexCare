import promptAction from '@ohos.promptAction'
import preferences from '@ohos.data.preferences'
import { http } from '@kit.NetworkKit'
import { LengthMetrics } from '@kit.ArkUI'

// 替换成你的 DeepSeek Key
const DASHSCOPE_API_KEY = 'sk-6bdecff061da44fb9c664e292ec69b52'

interface CheckRecord {
  time: string; part: string; level: number; types: string; note: string;
  aiReport?: string; onsetTime: string; duration: string;
}
interface AIMessage { role: string; content: string; }
interface AIRequestData { model: string; messages: AIMessage[]; }
interface AIMessageResponse { content: string; }
interface AIChoice { message: AIMessageResponse; }
interface AIResponse { choices: AIChoice[]; }

@Component
export struct BodyCheck {
  @State selectedPart: string = '未选择'
  @State painLevel: number = 4
  @State discomfortTypes: string[] = ['僵硬']
  @State note: string = ''
  @State onsetTime: string = '今天'
  @State duration: string = '断断续续'

  @Consume('globalRefresh') globalRefresh: number
  @State isGenerating: boolean = false
  @State showReportDialog: boolean = false
  @State aiReport: string = ''

  @State showExplodeDialog: boolean = false
  @State hoveredPart: string = ''

  selectMuscle(partName: string) {
    this.selectedPart = partName
    this.showExplodeDialog = false
  }

  showDatePicker() {
    let selectedDate = new Date()
    DatePickerDialog.show({
      start: new Date("2020-01-01"), end: new Date(), selected: selectedDate,
      onDateAccept: (value: Date) => {
        this.onsetTime = `${value.getFullYear()}-${(value.getMonth() + 1).toString().padStart(2, '0')}-${value.getDate().toString().padStart(2, '0')}`
      }
    })
  }

  async generateAIReport(): Promise<string> {
    const prompt = `你是一个专业的健康顾问。用户填写了一份身体自查报告，请根据以下信息生成一份简短的评估报告：
- 不适部位：${this.selectedPart}
- 不适类型：${this.discomfortTypes.join('、')}
- 不适程度（0-10）：${this.painLevel}
- 首次发生时间：${this.onsetTime}
- 持续时长特点：${this.duration}
- 备注：${this.note || '无'}
请按以下格式输出：\n【疼痛情况评估】\n【可能原因分析】\n【后续健康建议】`

    let httpRequest = http.createHttp()
    try {
      let messages: AIMessage[] = [{ role: 'user', content: prompt }]
      let requestBody: AIRequestData = { model: 'deepseek-flash', messages: messages }
      let response = await httpRequest.request(
        'https://api.deepseek.com/chat/completions',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${DASHSCOPE_API_KEY}` },
          extraData: JSON.stringify(requestBody),
          connectTimeout: 15000, readTimeout: 30000, expectDataType: http.HttpDataType.STRING
        }
      )
      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as AIResponse
        return result.choices[0].message.content
      } else if (response.responseCode === 401) { return 'Key 无效。' }
      else if (response.responseCode === 402) { return '余额不足。' }
      else { return `错误代码（${response.responseCode}）。` }
    } catch (err) {
      return '网络请求失败。'
    } finally { httpRequest.destroy() }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Blank()
          Text('身体自查').fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
          Text('📝').fontSize(20)
        }.width('100%').padding({ top: 16, bottom: 10, left: 16, right: 16 })

        Scroll() {
          Column({ space: 20 }) {

            // ================= 人体示意图 (仅正面) =================
            Column() {
              Stack() {
                Image($r('app.media.body_front'))
                  .width(300).height(300).objectFit(ImageFit.Contain)
                  .onClick(() => { this.showExplodeDialog = true })
              }
              .width(300).height(300)
            }
            .width('100%').backgroundColor('#FFFFFF').borderRadius(16).padding(16).margin({ top: 10 })

            if (this.selectedPart === '未选择') {
              Text('请点击上方人体图选择不适部位').fontSize(14).fontColor('#999999')
            } else {
              Text(`已选择：${this.selectedPart}`).fontSize(16).fontColor('#2E8B57').fontWeight(FontWeight.Bold)
            }

            // ============= 表单 =============
            Column({ space: 8 }) {
              Text('发生时间').fontSize(16).fontWeight(FontWeight.Bold)
              Row() {
                Text(this.onsetTime).fontSize(14).fontColor('#333333')
                Blank()
                Text('选择日期 >').fontSize(14).fontColor('#2E8B57')
              }.width('100%').padding(12).backgroundColor('#FFFFFF').borderRadius(12).onClick(() => { this.showDatePicker() })
            }.width('100%')

            Column({ space: 10 }) {
              Text('持续时长').fontSize(16).fontWeight(FontWeight.Bold)
              Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) {
                this.DurationChip('一直疼'); this.DurationChip('断断续续'); this.DurationChip('活动时疼'); this.DurationChip('休息时疼')
              }.width('100%')
            }.width('100%')

            Column({ space: 8 }) {
              Text('不适程度').fontSize(16).fontWeight(FontWeight.Bold)
              Slider({ value: this.painLevel, min: 0, max: 10, step: 1 }).width('100%').selectedColor('#2E8B57')
                .onChange((value: number) => { this.painLevel = Math.round(value) })
              Row() { Text('0').fontSize(12); Blank(); Text(this.painLevel.toString()).fontSize(14).fontColor('#2E8B57'); Blank(); Text('10').fontSize(12) }.width('100%')
            }.width('100%')

            Column({ space: 10 }) {
              Text('不适类型').fontSize(16).fontWeight(FontWeight.Bold)
              Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) {
                this.TypeChip('酸胀'); this.TypeChip('僵硬'); this.TypeChip('牵拉感'); this.TypeChip('刺痛')
              }.width('100%')
            }.width('100%')

            Column({ space: 8 }) {
              Text('备注').fontSize(16).fontWeight(FontWeight.Bold)
              TextArea({ placeholder: '补充说明，仅用于记录', text: this.note }).width('100%').height(80).backgroundColor('#F7F8FA').maxLength(50).onChange((value: string) => { this.note = value })
            }.width('100%')

            Button(this.isGenerating ? 'AI 正在分析...' : '生成自查记录并分析')
              .width('100%').height(48).backgroundColor(this.isGenerating ? '#A5D6A7' : '#2E8B57').fontColor('#FFFFFF')
              .enabled(!this.isGenerating)
              .onClick(async () => {
                if (this.selectedPart === '未选择') {
                  promptAction.showToast({ message: '请先选择不适部位' })
                  return
                }
                this.isGenerating = true
                try {
                  this.aiReport = await this.generateAIReport()
                  let record: CheckRecord = {
                    time: new Date().toLocaleString(), part: this.selectedPart, level: this.painLevel,
                    types: this.discomfortTypes.join('、'), note: this.note, aiReport: this.aiReport, onsetTime: this.onsetTime, duration: this.duration
                  }
                  let context = getContext(this)
                  let store = await preferences.getPreferences(context, 'FlexCareData')
                  let historyStr = await store.get('history', '[]') as string
                  let historyList: CheckRecord[] = JSON.parse(historyStr)
                  historyList.unshift(record)
                  await store.put('history', JSON.stringify(historyList))
                  await store.flush()
                  this.isGenerating = false; this.showReportDialog = true; this.globalRefresh++
                } catch (err) { this.isGenerating = false; promptAction.showToast({ message: '保存失败' }) }
              }).margin({ bottom: 30 })
          }.padding({ left: 20, right: 20 })
        }.layoutWeight(1)
      }.width('100%').height('100%')


      // ================= 悬浮爆炸图弹窗 =================
      if (this.showExplodeDialog) {
        Column() {
          Column({ space: 10 }) {
            Row() {
              Text('请选择不适肌群').fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1)
              Text('❌').fontSize(20).fontColor('#999999').onClick(() => { this.showExplodeDialog = false })
            }.width('100%').padding({ bottom: 10 })

            // 顶部动态提示文字
            Text(this.hoveredPart === '' ? '移动或按住下方肌肉图进行选择' : this.hoveredPart)
              .fontSize(18)
              .fontColor(this.hoveredPart === '' ? '#999999' : '#FF3232')
              .fontWeight(this.hoveredPart === '' ? FontWeight.Normal : FontWeight.Bold)
              .height(30)
              .width('100%')
              .textAlign(TextAlign.Center)

            // 核心：绝对定位摆放正面肌群图（完全保留你的坐标）
            Stack() {
              // --- 胸锁乳突肌（居中细条） ---
              this.MuscleItem($r('app.media.muscle_scm_right'), '右侧胸锁乳突肌', 25, 80, 135, 10)
              this.MuscleItem($r('app.media.muscle_scm_left'), '左侧胸锁乳突肌', 25, 80, 180, 10)

              // --- 斜方肌（内侧上方） ---
              this.MuscleItem($r('app.media.muscle_trapezius_right'), '右侧斜方肌', 60, 50, 78, 24)
              this.MuscleItem($r('app.media.muscle_trapezius_left'), '左侧斜方肌', 60, 50, 205, 24)

              // --- 三角肌（最外侧） ---
              this.MuscleItem($r('app.media.muscle_deltoid_right'), '右侧三角肌', 60, 70, 21, 75)
              this.MuscleItem($r('app.media.muscle_deltoid_left'), '左侧三角肌', 60, 70, 260, 75)

              // --- 胸小肌（内侧中，深层） ---
              this.MuscleItem($r('app.media.muscle_pectoralis_minor_right'), '右侧胸小肌', 80, 60, 70, 130)
              this.MuscleItem($r('app.media.muscle_pectoralis_minor_left'), '左侧胸小肌', 80, 60, 190, 130)

              // --- 胸大肌（最下方，浅层。渲染在最后，视觉上会在胸小肌上面） ---
              this.MuscleItem($r('app.media.muscle_pectoralis_major_right'), '右侧胸大肌', 80, 60, 70, 80)
              this.MuscleItem($r('app.media.muscle_pectoralis_major_left'), '左侧胸大肌', 80, 60, 190, 80)
            }
            .width(340).height(340)
            .backgroundColor('#F7F8FA')
            .borderRadius(16)
            .margin({ top: 10 })

          }
          .width('90%')
          .height('60%')
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .padding(20)
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.2)', offsetX: 0, offsetY: 10 })
        }
        .width('100%').height('100%').backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center).zIndex(100)
      }

      // Loading 和 AI 报告弹窗
      if (this.isGenerating) {
        Column() {
          LoadingProgress().width(60).height(60).color('#2E8B57')
          Text('AI 正在为您生成健康报告...').fontSize(16).fontColor('#FFFFFF').margin({ top: 16 })
        }.width('100%').height('100%').backgroundColor('rgba(0,0,0,0.6)').justifyContent(FlexAlign.Center).zIndex(10)
      }

      if (this.showReportDialog) {
        Column() {
          Column({ space: 16 }) {
            Row() {
              Text('✨ AI 智能健康报告').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#2E8B57').layoutWeight(1)
              Text('❌').fontSize(18).fontColor('#999999').onClick(() => { this.showReportDialog = false })
            }.width('100%').margin({ bottom: 10 })
            Scroll() { Text(this.aiReport).fontSize(15).fontColor('#333333').lineHeight(24).width('100%') }.layoutWeight(1).scrollBar(BarState.Off)
            Button('我知道了').width('100%').height(44).backgroundColor('#2E8B57').fontColor('#FFFFFF')
              .onClick(() => { this.showReportDialog = false; this.note = ''; this.painLevel = 4; this.discomfortTypes = ['僵硬'] })
          }.width('85%').height('75%').backgroundColor('#FFFFFF').borderRadius(20).padding(24).shadow({ radius: 20, color: 'rgba(0,0,0,0.2)', offsetX: 0, offsetY: 10 })
        }.width('100%').height('100%').backgroundColor('rgba(0,0,0,0.4)').justifyContent(FlexAlign.Center).zIndex(10)
      }
    }.width('100%').height('100%')
  }

  @Builder
  MuscleItem(imgRes: Resource, partName: string, w: number, h: number, x: number, y: number) {
    Image(imgRes)
      .width(w).height(h)
      .objectFit(ImageFit.Contain)
      .position({ x: x, y: y })
      // 鼠标悬停事件（电脑端有效）
      .onHover((isHover: boolean) => {
        if (isHover) {
          this.hoveredPart = partName
        } else if (this.hoveredPart === partName) {
          this.hoveredPart = ''
        }
      })
      // 触摸事件（真机/模拟器手指操作有效）
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.hoveredPart = partName
        }
        if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.hoveredPart = ''
        }
      })
      // 点击选中
      .onClick(() => { this.selectMuscle(partName) })

      // 视觉反馈：鼠标/手指放在上面时，该图片稍微放大，方便辨认
      .scale(this.hoveredPart === partName ? { x: 1.15, y: 1.15 } : { x: 1, y: 1 })
      .animation({ duration: 200 })
      .zIndex(this.hoveredPart === partName ? 99 : 1) // 悬浮的图片层级置顶
  }

  @Builder TypeChip(label: string) { Text(label).fontSize(14).padding({ left: 16, right: 16, top: 8, bottom: 8 }).backgroundColor(this.discomfortTypes.includes(label) ? '#2E8B57' : '#FFFFFF').fontColor(this.discomfortTypes.includes(label) ? '#FFFFFF' : '#666666').borderRadius(20).onClick(() => { if (this.discomfortTypes.includes(label)) { this.discomfortTypes = this.discomfortTypes.filter(item => item !== label) } else { this.discomfortTypes.push(label) } }) }
  @Builder DurationChip(label: string) { Text(label).fontSize(14).padding({ left: 16, right: 16, top: 8, bottom: 8 }).backgroundColor(this.duration === label ? '#2E8B57' : '#FFFFFF').fontColor(this.duration === label ? '#FFFFFF' : '#666666').borderRadius(20).onClick(() => { this.duration = label }) }
}