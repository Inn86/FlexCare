import { HomeView } from './HomeView'
import { BodyCheck } from './BodyCheck'
import { StretchCourse } from './StretchCourse'
import { History } from './History'

@Entry
@Component
struct Index {
  private tabsController: TabsController = new TabsController()
  @State currentIndex: number = 0
  // 提供全局刷新标记，每次保存数据后加 1
  @Provide('globalRefresh') @Watch('onRefreshChange') globalRefresh: number = 0

  onRefreshChange() {
    // 标记变化时不需要做啥，主要为了让子组件感知
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          HomeView({
            onSwitchTab: (index: number) => {
              this.currentIndex = index
              this.tabsController.changeIndex(index)
            }
          })
        }.tabBar(this.TabBuilder('首页', 0))

        TabContent() {
          BodyCheck()
        }.tabBar(this.TabBuilder('自查', 1))

        TabContent() {
          StretchCourse()
        }.tabBar(this.TabBuilder('课程', 2))

        TabContent() {
          History()
        }.tabBar(this.TabBuilder('历史', 3))
      }
      .width('100%').height('100%')
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .scrollable(true)
      .barMode(BarMode.Fixed)
    }
    .width('100%').height('100%').backgroundColor('#F7F8FA')
  }

  @Builder
  TabBuilder(title: string, index: number) {
    Column({ space: 4 }) {
      Circle().width(24).height(24).fill(this.currentIndex === index ? '#2E8B57' : '#CCCCCC')
      Text(title).fontSize(12).fontColor(this.currentIndex === index ? '#2E8B57' : '#999999')
    }
    .width('100%').height(60).justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index
      this.tabsController.changeIndex(index)
    })
  }
}