# CZInstagram

MVVM + FLUX iOS Instagram client in Swift, eliminates Massive View Controller in unidirectional event/state flow manner.

  <img src="./Docs/FLUX.png">
  
 
#### Unidirectional Data Flow
 * **Dispatcher:** Propagates domained events

 * **Store:** Maintains the State tree

 * **Subscriber:** Subscribes to Store and update Components/Views with new State

 * **Event:** Event driven - more loosely coupled than Delegation
    
 * **State:**
   * Waterfall reacting flow
   * Composition: RootState is composited by subStates
   * React(to:) Event and outputs new State, propagates Event to its children substate nodes

#### Demo Gif

<img src="./Docs/CZInstagram.gif">

#### Eliminate Massive View Controller
 * No more UICollectionViewDataSource/UICollectionViewDelegate overhead
 * No more long if statement to manage model/cell mapping, event handling
 * FLUX one way data flow solves core problems of MVC: 
   * Central Mediator
   * Event Propagration
   * Data Binding

#### ReactiveListViewKit facade view classes wrapp complex UICollectionView
 * Implement Instagram feedList within 50 lines of code
 * Embedded `HorizontalSectionAdapterView` makes nested horizontal ListView implementation within 10 lines of code
 * Adaptive to various CellComponent classes:
   * UICollectionViewCell
   * UIView
   * UIViewController - Domained event handling for complex cell
   
### Implemented on top of my open-source frameworks 
 * [**ReactiveListViewKit**](https://github.com/showt1me/ReactiveListViewKit) MVVM + FLUX Reactive Facade ViewKit, eliminates Massive View Controller in unidirectional event/state flow manner
 
 * [**CZWebImage**](https://github.com/showt1me/CZWebImage)
 Elegant progressive concurrent image downloading framework, with neat APIs, LRU mem/disk cache
 
 * [**CZNetworking**](https://github.com/showt1me/CZNetworking)
 Elegant progressive asynchronous HTTP request flow management framework, supports GET/PUT/POST/DELETE
 
 * [**CZJsonModel**](https://github.com/showt1me/CZJsonModel)
 Elegant JSON modeling framework in Swift


  