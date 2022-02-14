part of 'post_bloc.dart';

enum PostStatus { initial, success, failure }

class PostState extends Equatable {
  const PostState({
    this.status = PostStatus.initial,
    this.posts = const <Post>[],
    this.hasReachedMax = false,
  });

  final List<Post> posts;
  final bool hasReachedMax;
  final PostStatus status;

  @override
  List<Object> get props => [posts, hasReachedMax, status];

  PostState copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
    PostStatus? status,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'PostState(posts: $posts, hasReachedMax: $hasReachedMax, status: $status)';
}
