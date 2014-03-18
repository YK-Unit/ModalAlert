ModalAlert
============
It's Based Erica Sadun's [ModalAlert](https://github.com/erica/iphone-3.0-cookbook-/tree/master/C10-Alerts/02-Modal%20Alert), and it has add more features now:

* supports ARC and Non-ARC
* improves performance for iOS5+
* has more useful function methods

---
##Usage#
It's easy to use it, see the code snippeta below.

PS: You can get the all usages in the simple demo app.
 
```Obj-c
BOOL flag = [ModalAlert confirm:@"Do you know this phone number %d?",110];
NSLog(@"flag:%d",flag);
```

```Obj-c
NSInteger i = [ModalAlert ask:@"Which color do you like?" withCancel:@"None" withButtons:[NSArray arrayWithObjects:@"Blue",@"Red",nil]];
NSLog(@"the index is:%d",i);
```

```Obj-c
NSArray *array = [ModalAlert askUserNameAndPassword:@"Login" withNameKeyborType:UIKeyboardTypeEmailAddress withNameTextPrompt:@"username" withPasswordKeyborType:UIKeyboardTypeDefault withPasswordTextPrompt:@"password"];
            NSLog(@"the array is:%@",array);
```

---
##Attention#
**ModalAlert must be invoked in the main threan of a viewcontroller, for example**

It maybe work badly as a zombie like this:

```Obj-c
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [ModalAlert confirm:[NSString stringWithFormat:@"The index row is:%d",indexPath.row]];
}
```

It should do like this:

```Obj-c
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSelectorOnMainThread:@selector(doDealWithSelectionAtIndex:) withObject:indexPath waitUntilDone:NO];
}

- (void)doDealWithSelectionAtIndex:(NSIndexPath *)indexPath
{
   [ModalAlert confirm:[NSString stringWithFormat:@"The index row is:%d",indexPath.row]];
}
```
---
##License#
[BSD License](LICENSE)
