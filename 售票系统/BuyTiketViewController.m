//
//  BuyTiketViewController.m
//  售票系统
//
//  Created by RenSihao on 15/10/21.
//  Copyright © 2015年 RenSihao. All rights reserved.
//

#import "BuyTiketViewController.h"

@interface BuyTiketViewController ()

@property (nonatomic, assign) NSInteger surplusTicket; //剩余票数
@property (weak, nonatomic) IBOutlet UILabel *surplusLab; //剩余票数lab

@property (weak, nonatomic) IBOutlet UISwitch *userXiaoming; //乘客－小明
@property (weak, nonatomic) IBOutlet UISwitch *userXiaohong; //乘客－小红
@property (weak, nonatomic) IBOutlet UIButton *clear; //清空按钮
@property (weak, nonatomic) IBOutlet UIButton *buyTicketBtn; //购买按钮

@end

@implementation BuyTiketViewController

- (void)viewDidLoad
{
    //假如剩余一张票
    self.surplusTicket = 1;
    self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
    
}

- (IBAction)buyTicketBtnDidClick:(UIButton *)sender
{
//    //第一种方法
//    //模拟两个人同时点击购买
//    //创建两条线程，小明线程和小红线程
//    
//    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(buyTicket:) object:@"vip1"];
//    thread1.name = @"小明";
//    [thread1 start];
//    
//    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(buyTicket:) object:@"vip2"];
//    thread2.name = @"小红";
//    [thread2 start];
    
    
    //第二种方法
    //使用GCD 串行还是并行决定任务的执行方式是顺序执行还是并发执行，同步异步决定是否创建新线程（同步不创建，异步创建）
    //串行
    //[self serial];
    
    //并行
   // [self conc];
    
    //获取全局（并行队列）
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //同步
    for(int i=0; i<2; i++)
    {
        dispatch_sync(queue, ^{
            if(self.surplusTicket > 0)
            {
                self.surplusTicket --;
                
                NSLog(@"当前%@ 线程成功购买到一张票", [NSThread currentThread]);
                NSLog(@"系统剩余票数为%ld", self.surplusTicket);
                //self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
            }
            else
            {
                NSLog(@"当前%@ 线程购买失败,系统剩余票数为0", [NSThread currentThread]);
            }
            
        });
    }

    
    //把任务放在主队列（GCD自带的特殊串行队列）
    //主队列 异步执行任务：任务放到主队列之后，会先把当前主线程中当前的任务执行完毕，再去执行主队列中的新任务，不会创建新线程（特殊）
    //主队列 同步执行任务：会造成死锁
    [self mainQueue];
    
    //利用GCD的线程间通信
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       //加载耗时操作
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //返回UI主线程
        });
        
    });
    
    
    //iOS延时操作有两种
    //1、 NSObject方法－－－－3秒后调用delay
    [self performSelector:@selector(delay) withObject:nil afterDelay:3.0];
    
    //2、
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //延时3秒，异步运行此处代码块
        
    });
    
    
    
    //有点类似静态代码块
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //只执行一次的代码（这里默认是线程安全的，一般写静态全局变量、对象）
        
    });
    
    
    //需求：分别异步执行2个耗时操作，等2个异步操作都执行完毕，再回到主线程执行操作
    //创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    //获取全局并发队列 57行已经获取
    dispatch_group_async(group, queue, ^{
        //此处是耗时操作1
    });
    dispatch_group_async(group, queue, ^{
        //此处是耗时操作2
    });
    //给UI主线程发送通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //操作1和2均已执行完毕
    });
    
    
    //先同步后异步
    dispatch_queue_t concQueue = dispatch_queue_create("concQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(concQueue, ^{
        //
    });
    dispatch_async(concQueue, ^{
        //
    });
    
    
    //1 创建一个NSOperationQueue
    NSOperationQueue *nsQueue = [[NSOperationQueue alloc] init];
    
    for(int i=0; i<2; i++)
    {
        //2 创建一个NSOperation的子类对象
        NSOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invoca) object:nil];
        //[operation start];
        
        //3 把NSOperation对象添加到NSOperationQueue
        [nsQueue addOperation:operation];
    }
    
    //

    NSOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        //
            
    }];
    NSOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        //
            
    }];
    [nsQueue addOperations:@[operation1, operation2] waitUntilFinished:NO];//主队列中是否等待参数设置为NO

    
    //其它线程可以与主线程通信
    [nsQueue addOperationWithBlock:^{
        int a = 10;
        NSLog(@"第一个任务 %@", [NSThread currentThread]);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSLog(@"主线程任务 %@ a=%d", [NSThread currentThread], a);
        }];
    }];
    
    //设置最大并发数
    nsQueue.maxConcurrentOperationCount = 3;
    for(int i=0; i<10; i++)
    {
        [nsQueue addOperationWithBlock:^{
            //
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%@, 当前任务编号 %d",[NSThread currentThread], i);
        }];
    }
    
    //依赖关系
    
    //登录操作
    NSOperation *loginOP = [NSBlockOperation blockOperationWithBlock:^{
        //
        NSLog(@"%@ 登录操作", [NSThread currentThread]);
    }];
    
    //下载操作
    NSOperation *downloadOP = [NSBlockOperation blockOperationWithBlock:^{
        //
        NSLog(@"%@ 正在下载", [NSThread currentThread]);
    }];
    
    //主UI线程 显示“下载完成”操作
    NSOperation *showOP = [NSBlockOperation blockOperationWithBlock:^{
        //
        NSLog(@"%@ 下载完成", [NSThread currentThread]);
    }];
    
    //依赖关系设置可以跨队列
    //不要设置为循环依赖
    //依赖关系设置要放在 操作加入队列之前
    [downloadOP addDependency:loginOP];//下载依赖于登录
    [showOP addDependency:downloadOP];//显示依赖于登录
    
    [[NSOperationQueue mainQueue] addOperation:showOP];
    
    [nsQueue addOperations:@[loginOP, downloadOP] waitUntilFinished:NO];
    
}

//NSInvocationOperation start
- (void)invoca
{
    NSLog(@"%s", __func__);
}
- (void)serial
{
    //创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    for(int i=0; i<2; i++)
    {
        dispatch_sync(serialQueue, ^{
            if(self.surplusTicket > 0)
            {
                self.surplusTicket --;
                
                NSLog(@"当前%@ 线程成功购买到一张票", [NSThread currentThread]);
                NSLog(@"系统剩余票数为%ld", self.surplusTicket);
                //self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
            }
            else
            {
                NSLog(@"当前%@ 线程购买失败,系统剩余票数为0", [NSThread currentThread]);
            }
        });
    }
    
    
    //串行队列异步方式执行任务，创建新线程，并且任务顺序执行
    for(int i=0; i<2; i++)
    {
        dispatch_async(serialQueue, ^{
            if(self.surplusTicket > 0)
            {
                self.surplusTicket --;
                
                NSLog(@"当前%@ 线程成功购买到一张票", [NSThread currentThread]);
                NSLog(@"系统剩余票数为%ld", self.surplusTicket);
                //self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
            }
            else
            {
                NSLog(@"当前%@ 线程购买失败,系统剩余票数为0", [NSThread currentThread]);
            }
        });
    }
    
}
- (void)conc
{
    //创建并行队列
    dispatch_queue_t concQueue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
        //并行队列同步方式执行任务，不创建新线程，并且任务并发执行
    for(int i=0; i<2; i++)
    {
        dispatch_sync(concQueue, ^{
            if(self.surplusTicket > 0)
            {
                self.surplusTicket --;
                
                NSLog(@"当前%@ 线程成功购买到一张票", [NSThread currentThread]);
                NSLog(@"系统剩余票数为%ld", self.surplusTicket);
                //self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
            }
            else
            {
                NSLog(@"当前%@ 线程购买失败,系统剩余票数为0", [NSThread currentThread]);
            }
        });
    }
    
    //并行队列异步方式执行任务，创建新线程，并且任务并发执行
    for(int i=0; i<2; i++)
    {
        dispatch_async(concQueue, ^{
            if(self.surplusTicket > 0)
            {
                self.surplusTicket --;
                
                NSLog(@"当前%@ 线程成功购买到一张票", [NSThread currentThread]);
                NSLog(@"系统剩余票数为%ld", self.surplusTicket);
                //self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
            }
            else
            {
                NSLog(@"当前%@ 线程购买失败,系统剩余票数为0", [NSThread currentThread]);
            }
        });
    }
}

- (void)mainQueue
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    for(int i=0; i<2; i++)
    {
        dispatch_sync(queue, ^{
            if(self.surplusTicket > 0)
            {
                self.surplusTicket --;
                
                NSLog(@"当前%@ 线程成功购买到一张票", [NSThread currentThread]);
                NSLog(@"系统剩余票数为%ld", self.surplusTicket);
                //self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
            }
            else
            {
                NSLog(@"当前%@ 线程购买失败,系统剩余票数为0", [NSThread currentThread]);
            }
        });
    }

}
- (void)delay
{
    
}

//清空选中的乘客
- (IBAction)clear:(UIButton *)sender
{
    self.userXiaohong.on = NO;
    self.userXiaoming.on = NO;
}

//购买线程执行方法
- (void)buyTicket:(NSString *)object
{
    /*----------------第一种方法----------------------
     
    //如果vip1线程先进来，设置其睡眠3秒，即优先处理vip2线程
    if([object isEqualToString:@"vip1"])
    {
       [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    }
    if(self.surplusTicket > 0)
    {
        self.surplusTicket --;
        
        NSLog(@"当前%@ 线程成功购买到一张票", [NSThread currentThread]);
        NSLog(@"系统剩余票数为%ld", self.surplusTicket);
        //self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
    }
    else
    {
        NSLog(@"当前%@ 线程购买失败,系统剩余票数为0", [NSThread currentThread]);
    }
     */
    
    
    
    
    
}




@end
