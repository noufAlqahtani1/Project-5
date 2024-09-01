import 'dart:io';

import 'package:blogs_app/screens/blog_detail_screen.dart';
import 'package:blogs_app/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../data/services/blog_service.dart';
import '../helper/locator.dart';
import '../models/blog.dart';

class ExploreScreen extends StatefulWidget {
  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final BlogService blogService = locator<BlogService>();
  List<Blog> allBlogs = [];
  List<Blog> filteredBlogs = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadBlogs();
    searchController.addListener(() {
      filterBlogs(searchController.text);
    });
  }

  void loadBlogs() {
    setState(() {
      allBlogs = blogService.getBlogs();
      filteredBlogs = allBlogs;
    });
  }

  void filterBlogs(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredBlogs = allBlogs;
      });
    } else {
      setState(() {
        filteredBlogs = allBlogs.where((blog) {
          return blog.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    appBar: AppBar(backgroundColor: Colors.black,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchField(
              controller: searchController,
              onChanged: filterBlogs,
            ),
            SizedBox(height: 16.0), 
            Expanded(
              child: filteredBlogs.isEmpty
                  ? Center(child: Text('No blogs found.'))
                  : ListView.builder(
                      itemCount: filteredBlogs.length,
                      itemBuilder: (context, index) {
                        Blog blog = filteredBlogs[index];
                        return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(30, 30, 30, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(blog.postImage),
                              height: 62,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            blog.authorName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            blog.summary,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlogDetailScreen(blog: blog),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: Icon(
                                blog.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (!blog.isSaved) {
                                    blogService.saveBlog(blog);
                                    blog.isSaved = true;
                                  }
                                });
                              },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 6),
                          child: Row(
                            children: [
                              Text(
                                "${blog.date} • ${blog.minutesToRead.toString()}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}