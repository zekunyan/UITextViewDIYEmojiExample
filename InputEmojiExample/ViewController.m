//
//  ViewController.m
//  InputEmojiExample
//
//  Created by zorro on 15/3/6.
//  Copyright (c) 2015年 tutuge. All rights reserved.
//

#import "ViewController.h"
#import "EmojiTextAttachment.h"
#import "NSAttributedString+EmojiExtension.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) NSArray *emojiTags;
@property (strong, nonatomic) NSArray *emojiImages;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init
    _emojiTags = @[@"[/emoji_1]", @"[/emoji_2]", @"[/emoji_3]", @"[/emoji_4]"];
    _emojiImages = @[[UIImage imageNamed:@"emoji_1"], [UIImage imageNamed:@"emoji_2"],
            [UIImage imageNamed:@"emoji_3"], [UIImage imageNamed:@"emoji_4"]];

    //Init text font
    [self resetTextStyle];

    //Add keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetTextStyle {
    //After changing text selection, should reset style.
    NSRange wholeRange = NSMakeRange(0, _textView.textStorage.length);

    [_textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];

    [_textView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22.0f] range:wholeRange];
}

#pragma mark - Action

- (IBAction)insertEmoji:(UIButton *)sender {
    //Create emoji attachment
    EmojiTextAttachment *emojiTextAttachment = [EmojiTextAttachment new];

    //Set tag and image
    emojiTextAttachment.emojiTag = _emojiTags[(NSUInteger) sender.tag];
    emojiTextAttachment.image = _emojiImages[(NSUInteger) sender.tag];

    //Insert emoji image
    [_textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment]
                                          atIndex:_textView.selectedRange.location];

    //Move selection location
    _textView.selectedRange = NSMakeRange(_textView.selectedRange.location + 1, _textView.selectedRange.length);

    //Reset text style
    [self resetTextStyle];
}

- (IBAction)showPlainText:(id)sender {
    _infoLabel.text = [NSString stringWithFormat:@"Output: %@", [_textView.textStorage getPlainString]];
}

#pragma mark - Keyboard notification

- (void)onKeyboardNotification:(NSNotification *)notification {
    //Reset constraint constant by keyboard height
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect keyboardFrame = ((NSValue *) notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        _bottomConstraint.constant = keyboardFrame.size.height;
    } else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        _bottomConstraint.constant = 0;
    }
    
    //Animate change
    [UIView animateWithDuration:0.8f animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
