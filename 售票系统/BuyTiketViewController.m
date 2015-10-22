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
    self.surplusTicket = 2;
    self.surplusLab.text = [NSString stringWithFormat:@"%ld张", self.surplusTicket];
    
}

- (IBAction)buyTicketBtnDidClick:(UIButton *)sender
{
    //模拟两个人同时点击购买
    //创建两条线程，小明线程和小红线程
    
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(buyTicket:) object:@"vip1"];
    thread1.name = @"小明";
    [thread1 start];
    
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(buyTicket:) object:@"vip2"];
    thread2.name = @"小红";
    [thread2 start];
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
