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

//Emoji default max size
static const CGFloat EMOJI_MAX_SIZE = 64;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UISlider *emojiSizeSlider;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) NSArray *emojiTags;
@property (strong, nonatomic) NSArray *emojiImages;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init
    _emojiTags = @[@"[/emoji_1]", @"[/emoji_2]", @"[/emoji_3]", @"[/emoji_4]"];
    _emojiImages = @[[UIImage imageNamed:@"emoji_1_big"], [UIImage imageNamed:@"emoji_2_big"],
            [UIImage imageNamed:@"emoji_3_big"], [UIImage imageNamed:@"emoji_4_big"]];

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
    
    //Set emoji size
    emojiTextAttachment.emojiSize = CGSizeMake(_emojiSizeSlider.value * EMOJI_MAX_SIZE, _emojiSizeSlider.value * EMOJI_MAX_SIZE);

    // begin: changed by liu wei zhen: <<<
    NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:emojiTextAttachment];
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.length > 0) {
        [self.textView.textStorage deleteCharactersInRange:selectedRange];
    }
    //Insert emoji image
    [self.textView.textStorage insertAttributedString:str atIndex:self.textView.selectedRange.location];
    
    self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location+1, 0); // self.textView.selectedRange.length
    // end >>>

    //Move selection location
    //_textView.selectedRange = NSMakeRange(_textView.selectedRange.location + 1, _textView.selectedRange.length);

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
