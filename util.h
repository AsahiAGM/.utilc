#ifndef UTIL_H
# define UTIL_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <math.h>
#include <unistd.h>

struct ListNode {
    int val;
    struct ListNode *next;
};

void print_str(const char *arr, int size);
void print_nums(const int *arr, int size);
void arrs_free(void **arrs, size_t arrssize);
void print_llist(struct ListNode* list);
void list_free(struct ListNode* list);

#endif