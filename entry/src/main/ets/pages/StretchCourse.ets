import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

// 定义课程数据结构
interface Course {
  id: string;
  title: string;
  part: string;
  duration: number; // 秒
  steps: string[];
  caution: string;
}

@Component
export struct StretchCourse {
  // 页面状态：'list' (列表), 'detail' (详情), 'exercise' (倒计时), 'feedback' (评价)
  @State pageState: string = 'list'
  @State currentCourse: Course | null = null

  // 倒计时状态
  @State timeLeft: number = 0
  @State isPlaying: boolean = false
  private timerId: number = -1

  // 静态课程数据（后续可以改成从数据库读）
  private courses: Course[] = [
    {
      id: 'c1',
      title: '颈部侧屈拉伸',
      part: '颈部',
      duration: 30,
      steps: ['坐直或站直，肩膀放松。', '缓慢将头向左侧倾斜，感受右侧颈部拉伸。', '保持 15 秒，回正，再换右侧。'],
      caution: '动作要缓慢，不要用力过猛，避免引起头晕。'
    },
    {
      id: 'c2',
      title: '肩胛放松练习',
      part: '肩部',
      duration: 45,
      steps: ['双手交叉放在脑后。', '双肘向后打开，感受肩胛骨向中间挤压。', '保持 5 秒后放松，重复动作。'],
      caution: '如果肩膀有明显刺痛感，请立即停止。'
    },
    {
      id: 'c3',
      title: '腰背温和伸展',
      part: '腰背',
      duration: 60,
      steps: ['平躺在瑜伽垫上，双膝弯曲。', '双手抱住右膝，缓慢拉向胸口。', '保持 20 秒，换另一侧。'],
      caution: '腰椎间盘突出急性期请勿做此动作。'
    }
  ]

  aboutToDisappear() {
    this.stopTimer()
  }



  // 开始倒计时
  startTimer() {
    this.isPlaying = true
    this.timerId = setInterval(() => {
      if (this.timeLeft > 0) {
        this.timeLeft--
      } else {
        this.stopTimer()
        this.pageState = 'feedback' // 倒计时结束，进入评价页
      }
    }, 1000)
  }

  // 暂停
  pauseTimer() {
    this.isPlaying = false
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
    }
  }

  // 停止并清理
  stopTimer() {
    this.isPlaying = false
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  // 提交体验反馈
  submitFeedback(feeling: string) {
    // 在这里你可以把打卡记录和反馈存进数据库
    promptAction.showToast({ message: `打卡成功！感受：${feeling}` })
    this.pageState = 'list'
    this.currentCourse = null
  }

  build() {
    Column() {
      // ================== 1. 课程列表页 ==================
      if (this.pageState === 'list') {
        Row() {
          Blank()
          Text('拉伸课程').fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
          Text('⚙️').fontSize(20)
        }.width('100%').padding({ top: 16, bottom: 10, left: 16, right: 16 })

        Scroll() {
          Column({ space: 16 }) {
            ForEach(this.courses, (course: Course) => {
              this.CourseCard(course)
            }, (course: Course) => course.id)
          }.padding({ left: 20, right: 20, bottom: 40 })
        }.layoutWeight(1)
      }

      // ================== 2. 课程详情页 ==================
      if (this.pageState === 'detail' && this.currentCourse) {
        // 顶部返回栏
        Row() {
          Text('< 返回').fontSize(16).fontColor('#2E8B57')
            .onClick(() => { this.pageState = 'list' })
          Blank()
        }.width('100%').padding(16)

        Column({ space: 20 }) {
          Text(this.currentCourse.title).fontSize(24).fontWeight(FontWeight.Bold).width('100%')

          // 示意图占位
          Column() {
            Text('动作示意图 (占位)').fontSize(16).fontColor('#999999')
          }.width('100%').height(200).backgroundColor('#E8F5E9').borderRadius(16).justifyContent(FlexAlign.Center)

          Text(`持续时间：${this.currentCourse.duration} 秒`).fontSize(16).fontColor('#2E8B57').width('100%')

          Column({ space: 8 }) {
            Text('动作步骤').fontSize(18).fontWeight(FontWeight.Bold).width('100%')
            ForEach(this.currentCourse.steps, (step: string, index: number) => {
              Text(`${index + 1}. ${step}`).fontSize(15).fontColor('#333333').lineHeight(24).width('100%')
            })
          }.width('100%')

          Column({ space: 8 }) {
            Text('⚠️ 注意事项').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#D32F2F').width('100%')
            Text(this.currentCourse.caution).fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
          }.width('100%')

          Blank()

          Button('准备好了，开始')
            .width('100%').height(48).backgroundColor('#2E8B57').fontColor('#FFFFFF')
            .onClick(() => {
              this.timeLeft = this.currentCourse!.duration
              this.pageState = 'exercise'
              this.startTimer()
            })
        }.padding({ left: 20, right: 20, bottom: 30 }).layoutWeight(1)
      }

      // ================== 3. 倒计时页 ==================
      if (this.pageState === 'exercise' && this.currentCourse) {
        Column({ space: 30 }) {
          Text(this.currentCourse.title).fontSize(22).fontWeight(FontWeight.Bold).margin({ top: 40 })

          // 倒计时大圆盘（进度条效果）
          Stack() {
            Progress({ value: this.timeLeft, total: this.currentCourse.duration, type: ProgressType.Ring })
              .width(200).height(200).color('#2E8B57').style({ strokeWidth: 12 })

            Text(`${this.timeLeft}`).fontSize(50).fontWeight(FontWeight.Bold).fontColor('#2E8B57')
            Text('秒').fontSize(16).fontColor('#666666').margin({ top: 70 })
          }.width(220).height(220)

          Text('请跟随步骤，缓慢呼吸').fontSize(16).fontColor('#666666')

          Row({ space: 20 }) {
            if (this.isPlaying) {
              Button('暂停').width(120).height(44).backgroundColor('#E8F5E9').fontColor('#2E8B57')
                .onClick(() => { this.pauseTimer() })
            } else {
              Button('继续').width(120).height(44).backgroundColor('#2E8B57').fontColor('#FFFFFF')
                .onClick(() => { this.startTimer() })
            }
            Button('结束').width(120).height(44).backgroundColor('#F0F4F8').fontColor('#666666')
              .onClick(() => {
                this.stopTimer()
                this.pageState = 'feedback'
              })
          }.margin({ top: 20 })
        }.width('100%').height('100%')
      }

      // ================== 4. 体验评价页 ==================
      if (this.pageState === 'feedback') {
        Column({ space: 20 }) {
          Text('打卡完成！').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#2E8B57').margin({ top: 60 })
          Text('刚才的拉伸感觉怎么样？').fontSize(16).fontColor('#666666')

          Column({ space: 16 }) {
            this.FeedbackButton('感觉更轻松了', '轻松', '#E8F5E9', '#2E8B57')
            this.FeedbackButton('没有明显变化', '无变化', '#F0F4F8', '#666666')
            this.FeedbackButton('感觉更不舒服', '不适', '#FFEBEE', '#D32F2F')
          }.width('80%').margin({ top: 40 })
        }.width('100%').height('100%')
      }

    }
    .width('100%').height('100%')
  }

  @Builder
  CourseCard(course: Course) {
    Column({ space: 10 }) {
      Row() {
        Text(course.title).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1)
        Text(`建议 ${course.duration} 秒`).fontSize(12).fontColor('#999999')
      }.width('100%')

      Row({ space: 8 }) {
        this.Tag(course.part, '#E8F5E9', '#2E8B57')
      }.width('100%')

      Button('查看详情').width('100%').height(40).backgroundColor('#C8E6C9').fontColor('#2E8B57')
        .onClick(() => {
          this.currentCourse = course
          this.pageState = 'detail'
        })
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
  }

  @Builder
  Tag(text: string, bg: string, color: string) {
    Text(text).fontSize(12).padding({ left: 10, right: 10, top: 4, bottom: 4 }).backgroundColor(bg).fontColor(color).borderRadius(12)
  }

  @Builder
  FeedbackButton(text: string, tag: string, bg: string, color: string) {
    Button(text)
      .width('100%').height(50).backgroundColor(bg).fontColor(color)
      .border({ width: 1, color: color })
      .onClick(() => { this.submitFeedback(tag) })
  }
}