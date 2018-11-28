---
layout: post
title: 在Angularjs里正确$apply的方法
tags:
    - AngularJS
categories: [Tech]
---
数据视图绑定原理
===============
我们都知道Angularjs的数据-视图绑定功能，如下面的这个视图

{% highlight html %}
{% raw %}
<div ng-controller="Ctrl">
  {{message}}
</div>
{% endraw %}
{% endhighlight %}

{% highlight javascript %}
function Ctrl($scope) {
  $scope.message = "hello world";
}
{% endhighlight %}

如果我们想在隔段时间后更新message，那么我们向controller添加如下代码

{% highlight javascript %}
function Ctrl($scope) {
  $scope.message = "hello world";
  setTimeout(function (){
       $scope.message = "update hello world";
  }, 2000)
}
{% endhighlight %}

我们期待两秒后message会更新，但实际情况并非如此。这与Angularjs数据绑定的实现机制有关系。其实要实现数据绑定，也就是得到数据改变的通知，最容易想到的有两种思路。

原生API
-------------------------------------------------
即Object.watch(Mozilla)，Object.observe。 这个方法适用于最新的js解释器，在V8下可以写如下代码，观察对象的属性的变化。优点是性能最好，所有对象都能够实现监控，缺点是兼容性问题。

{% highlight javascript %}
a={"x": 1};
Object.observe(a, function (infos){
	var info=infos[0];
	console.log(info.name + " changed")
});
a.x=2;

//输出
"x changed"
{% endhighlight %}

在回调函数中监控
------------------------------

这个很好理解，我们要求调用者写代码时

{% highlight javascript %}
a.x=2;
{% endhighlight %}
  要写成
{% highlight javascript %}
a.set("x", 2);
{% endhighlight %}

  那么 a 就是这么个对象
{% highlight javascript %}
var a = {
    set: function (key, value){ 
         this[key] = value;
         ...
         console.log(key + " changed");
    }
};
{% endhighlight %}

我们在a的set方法中埋一个钩子，就可以监控到a的属性改变，这个方法的优点是容易实现，也很容易理解。缺点也显而易见。

* 它依赖于约定。如果有人写了 a.y="5"; 它是监控不到这个变化的
* 不是所有的对象都支持绑定，只有一些特殊内置了set方法的对象，才能支持绑定

采用这种实现方式的有 [EmberJS](http://emberjs.org) 和 [KnockoutJS](http://knockoutjs.org/)。那就不难理解以下两条规则了。

* 在Emberjs里，所有observable的对象必须用Ember.Object.create这个工厂方法创建
* 在Knockout里，observable对象须用 ko.observable 装饰

另外一个需要关注的问题是Model的触发视图的更新时机，在Knockout官网上里有如下例子：
{% highlight html %}
{% raw %}
<p>First name: <strong data-bind="text: firstName">todo</strong></p>
<p>Last name: <strong data-bind="text: lastName">todo</strong></p>
<p>Fullname: <strong data-bind="text: fullName">todo</strong></p>
<button data-bind="click: capitalizeLastName">test</button>
{% endraw %}
{% endhighlight %}

{% highlight javascript %}
// This is a simple *viewmodel* - JavaScript that defines the data and behavior of your UI
function AppViewModel() {
    this.firstName = ko.observable("Bert");
    this.lastName = ko.observable("Bertington");
    this.fullName=ko.computed(function () {
        return this.firstName() + " " + this.lastName();
    }, this);
    this.capitalizeLastName = function () {
        var currentVal = this.lastName();
        this.firstName("bang");
        debugger;
        this.lastName(currentVal.toUpperCase());
    };
}

// Activates knockout.js
ko.applyBindings(new AppViewModel());
{% endhighlight %}

当我们点击test按钮时，capitalizeLastName 这个函数会就会一行一行的执行，注意我们的debugger语句，当 this.firstName("bang"); 执行完毕后我们中断了程序。这个时候观察视图，发现视图中的firstName已经变成bang了。我们继续程序执行this.lastName(currentVal.toUpperCase()); 这句执行完毕时，lastName才被全部大写。这似乎没有什么神奇的地方。我们注意到使用这种方式。

* 视图更新次数频繁，每次Model的改变都会触发视图的更新。**它更关注对象什么时候发生了变化**。
* **数据一致性有保证**，例如我在上面对firstName赋值，下面的代码要用到这个值的时候，已经知道firstName的最新的值是什么，调用 this.firstName() 即可。

只有理解了这两点，才能继续往下看，理解Angular的与众不同。

Angular的方式
-------------

Angular看这个问题的角度很新颖，Angular的绑定不用制造特殊对象，任何对象它都支持绑定，它的原理大致是这样的。

我们发现网页上界面刷新操作都对应一个具体的事件。例如最常用的，点击造成界面刷新，定时器到时触发刷新，AJAX请求返回触发刷新等。因此，Angular封装了一些常用的操作函数ng-click, $timeout,$http等。异步的操作采用Promise封装。当这个Promise处于complete状态，我们就触发一次$digest操作(同步的方法视为马上complete)。$digest的目的就在于检查被监控的对象是否发生了变化。

这里我们看到Angularjs跟上面方式的区别，**Angular不关注对象什么时候发生了变化，关注的是事件引起了那些变化**。在该事件结束后，统一刷新界面。这样做的好处是不会产生过多的视图渲染，假设我们要做一个聊天消息列表，我们可以写如下代码，而不用担心聊天界面被渲染两次，毕竟每次渲染需要大量的CPU计算，给用户的感觉会“卡”。

{% highlight javascript %}
// 以下代码在某个$http回调中
scope.msgList = $scope.msgList.concat(newMsgList)); //第一次赋值
var msgListLength = $scope.msgList.length;
$scope.msgList = $scope.msgList.slice(msgListLength - 200, msgListLength); // 第二次赋值，只保留200条最新消息

// 对msgList的操作不会引起View的重绘
{% endhighlight %}

 我们虽然对msgList进行了两次赋值，但是真正的渲染只会在$http结束后渲染一次。
下面我们结合代码更加详细的分析一下这个过程。
<a class="jsbin-embed" href="http://jsbin.com/sorise/1/embed?js,output">JS Bin</a>
在视图中，我们声明了两个watcher，a和b。我们这时点击test按钮，我们可以想象代码中最后会执行$scope.$digest()方法。为了证明它真的是这样工作的，我们打开调试器，当代码中断在debugger语句时，$scope.a已经发生了变化，但是视图并未立即更新。而是在xxClick执行完毕后更新（实际上是在$digest后更新，而$digest是由本文的主角$apply触发）。


然后请大家想两个问题：

1. 我们知道具体什么时候a发生了变化吗？<a href="javascript:void(0);" data-display=".answser1">显示答案</a>
    <span class="answser1">我们不知道精确的时间，但是我们知道是在xxClick后我们通过检查与旧值的对比，发现a发生了变化。在knockout中我们可以知道一个对象改变的精确时间，在Angular里，我们不知道。除非你刻意写代码，在每个改变a的地方打个时间戳。</span>

2. 我们是怎么知道我们监控了那些对象？<a href="javascript:void(0);" data-display=".answser2">显示答案</a>
    <span class="answser2">有两种办法:</span>
    <span class="answser2">1. 我们看到$scope下有a,b,c三个属性，那么我们是否需要监控a,b,c三个值得变化呢，要解答这个问题要看View，在View中我们只引用了a和b，并没有涉及到c，所以只有a和b两个watcher。</span>
    <span class="answser2">2. 使用$scope.$watch("c", function () {}) 这样我们通过代码的方式手工增加了一个watcher。</span>
    <span class="answser2">注：实际上，我们监控的对象也可以是一个表达式，例如{{ a | somefilter }}，但是它们本质上是一样的，只要a发生了变化，就将这个表达式重新计算，计算结果更新到视图上。</span>

我们看到Angularjs的实现方法严格意义上讲，应该归类于第二种，是基于函数的回调检查变化，但是它从宏观角度着眼，不纠结于单个属性的变化，而是关注事件触发后，我要关注的对象都发生了什么改变。

但是，这样带来一个数据一致性的问题。当view中有多个watcher时，a的变化可能会引起b的变化，而watcher监听器的执行总会有个先后顺序，在单个$digets循环中，如果b的监听器先于a执行，那么a变化之后，那么b在本次$digest中就感知不到a的变化。更麻烦的时，a的变化有可能引起e的变化，e的变化又改变了b，那么怎么解决这个问题。

Angular的解决方式是，在单次$digest结束后，如果watch的expression的值计算以后，发现发生了变化就标记本次$digest的结果为dirty，再执行一次$digest，如果结果还是dirty 那就再执行一次，直到dirty为false为止。这就是Angular中**dirty-check（脏检查）**的来历。Angular中对这个检查次数有个10的上限，如果$digest超过10次，会抛异常。我们可以看出来Angularjs里**双向绑定**并不神秘，而且只是一种概念，从Angular开发者的角度来看，根本不存在所谓的**双向绑定**，只是不同的事件在触发$digest而已。

注：我们也可以把a也理解为一个expression，即(a)

Angular里的数据视图绑定
=======================
通过上文，我们了解了Angular中model到view的data binding的实现，现在回到开头的问题，在Angular中怎么正确的进行视图更新。通过上面的原理我们知道，其实只需要触发$digest就可以了，我么可以通过调用$scope.$digest();实现界面刷新。
<a class="jsbin-embed" href="http://jsbin.com/lepoya/1/embed?js,output">JS Bin</a>
但是直接$digest是有一定风险的，因为$digest是会抛异常（还记得那个10次限制吗）。所以我们一般直接调用$apply，我们看Angular里$apply的源码

{% highlight javascript %}
$apply: function(expr) {
        try {
          beginPhase('$apply');
          return this.$eval(expr);
        } catch (e) {
          $exceptionHandler(e);
        } finally {
          clearPhase();
          try {
            $rootScope.$digest();
          } catch (e) {
            $exceptionHandler(e);
            throw e;
          }
        }
      }
{% endhighlight %}
我们看到$apply可以触发$digest，并且捕捉了异常，因此有下面代码达到同样的效果
<a class="jsbin-embed" href="http://jsbin.com/sasudo/1/embed?js,output">JS Bin</a>
注意我们使用$apply触发刷新，这样相对来说就比较安全了，它会处理$digest的异常。
我们注意到，$apply还可以接受一个js expression，因此下面这种写法也是可以的
<a class="jsbin-embed" href="http://jsbin.com/cicuv/1/embed?js,output">JS Bin</a>
或者
<a class="jsbin-embed" href="http://jsbin.com/zulumu/1/embed?js,output">JS Bin</a>
它们的区别就是，**在$apply里的expression异常会被Angularjs捕捉处理，不会导致整个Angular应用的崩溃**，这一点儿对一个webapp来说是至关重要的。
但是这样做有时候还会有问题，有时候我们会遇到这个错误 **"$digest already in progress"** 这是怎么回事呢。

处理$digest错误
=======================
Angular里有许多内置的directive，这些directive会自动的执行$apply，比如$timeout，$http这些常用的模块
<a class="jsbin-embed" href="http://jsbin.com/xoxoti/1/embed?js,output">JS Bin</a>
在这些内置的directive里，我们不需要手动$apply，Angular会自动帮我们做。我们的上述代码，实际上相当于如下**想象的**代码(注意注释的代码)， 使用Promise很容易实现。

{% highlight javascript %}
function Ctrl($scope,$timeout){
    $scope.msg="hello";
    $timeout(function () {
        $scope.msg = "world";
     },1000)/*.always(function () { $scope.$apply(); });*/
}
{% endhighlight %}

在实际项目中，我们经常需要使用外部库jQuery等与Angular结合，以提高性能，或者方便的实现Angular中没有的功能。
<a class="jsbin-embed" href="http://jsbin.com/piromo/1/embed?js,output">JS Bin</a>
updateMsg是一个公共方法，有可能在Angular的directive里调用，也有可能在jquery的回调函数里调用，$http请求完成后会执行我们代码中的$apply()，之前也说过$http方法是会自动$apply的，所以等于是**在$apply里又执行了$apply**，发生状态错误。所以就会出现**"$digest already in progress"** 的错误，但在jquery的click回调里没有这个问题。 这种场景在Angular和jquery混用的时候是非常常见的。那么我们如何简单方便的解决这个问题呢，答案非常简单:

{% highlight javascript %}
function Ctrl($scope,$timeout, $http){
    $scope.msg="hello";
  
    function updateMsg () {
        $scope.msg="world";
        $scope.$apply();
    }
    
    function updateMsgWrapper(){
      $timeout(updateMsg,0);
    }
  
    $http.get("/").success(updateMsgWrapper);
    $("#test").click(updateMsgWrapper);
}
{% endhighlight %}

相信我啰嗦了这么多，大家都明白为什么这样做能解决问题了。这样做的好处是没有额外的代码，并且兼容angular和Non-Angular的情况。流行的还有一种方法，过于geek，不推荐使用，仅供参考:
<a class="jsbin-embed" href="http://jsbin.com/sohuli/1/embed?js,output">JS Bin</a>
$$phase保存$digest状态机的当前状态。

<script src="http://static.jsbin.com/js/embed.js"></script>
